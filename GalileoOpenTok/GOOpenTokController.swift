
import Foundation
import ReactiveCocoa

protocol GOOpenTokControllerMessagingDelegate {
    
    func didRecieveMessage(messageType:String, message:String)
    
}

class GOOpenTokController : NSObject {
    
    var messagingDelegate: GOOpenTokControllerMessagingDelegate?
    var videoContainerView: UIView?
    
    var errorSignal : Signal<String, NoError>!
    private var errorObserver : Observer<String, NoError>!
    
    var session : OTSession?
    var publisher : OTPublisher?
    var subscriber : OTSubscriber?

    let model: GOModel
    
    init(model:GOModel) {
        
        self.model = model

        super.init()
        
        let (signal, observer) = Signal<String, NoError>.pipe()
        self.errorSignal = signal
        self.errorObserver = observer
        
        // When call is disconnected, video is neccesarily not in progress
        self.model.isOpenTokConnected.producer.startWithNext { (next:Bool) in
            if (!next) {
                self.model.isVideoCallInProgress.value = false
            }
        }
        
        session = OTSession(apiKey: self.model.apiKey, sessionId: self.model.sessionId, delegate: self)
    }
    
    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    func connect() {
        if let session = self.session {
            var maybeError : OTError?
            session.connectWithToken(self.model.token, error: &maybeError)
            if let error = maybeError {
                self.errorObserver.sendNext(error.localizedDescription)
            }
        }
    }
    
    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    func publish() {
        publisher = OTPublisher(delegate: self)
        
        publisher?.publishAudio = false
        
        var maybeError : OTError?
        session?.publish(publisher, error: &maybeError)
        
        if let error = maybeError {
            self.errorObserver.sendNext(error.localizedDescription)
        }
    }
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    func subscribe(stream : OTStream) {
        if let session = self.session {
            subscriber = OTSubscriber(stream: stream, delegate: self)
            
            var maybeError : OTError?
            session.subscribe(subscriber, error: &maybeError)
            if let error = maybeError {
                self.errorObserver.sendNext(error.localizedDescription)
            }
        }
    }
    
    /**
     * Cleans the subscriber from the view hierarchy, if any.
     */
    func unsubscribe() {
        if let subscriber = self.subscriber {
            var maybeError : OTError?
            session?.unsubscribe(subscriber, error: &maybeError)
            if let error = maybeError {
                self.errorObserver.sendNext(error.localizedDescription)
            }
            
            subscriber.view.removeFromSuperview()
            self.subscriber = nil
        }
    }
}


 // MARK: - OTSessionDelegate callbacks
extension GOOpenTokController : OTSessionDelegate {

    func sessionDidConnect(session: OTSession) {
        NSLog("sessionDidConnect (\(session.sessionId))")
        
        // Step 2: We have successfully connected, now instantiate a publisher and
        // begin pushing A/V streams into OpenTok.
        self.model.isOpenTokConnected.value = true
        publish()
    }
    
    func sessionDidDisconnect(session : OTSession) {
        NSLog("Session disconnected (\( session.sessionId))")
        self.model.isOpenTokConnected.value = false
    }
    
    func session(session: OTSession, streamCreated stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        
        // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
        // have seen on the OpenTok session.
        if subscriber == nil && !SubscribeToSelf {
            subscribe(stream)
        }
    }
    
    func session(session: OTSession, streamDestroyed stream: OTStream) {
        NSLog("session streamDestroyed (\(stream.streamId))")

        self.model.isVideoCallInProgress.value = false
        
        if subscriber?.stream.streamId == stream.streamId {
            unsubscribe()
        }
    }
    
    func session(session: OTSession, connectionCreated connection : OTConnection) {
        NSLog("session connectionCreated (\(connection.connectionId))")
    }
    
    func session(session: OTSession, connectionDestroyed connection : OTConnection) {
        NSLog("session connectionDestroyed (\(connection.connectionId))")
        self.model.isVideoCallInProgress.value = false
    }
    
    func session(session: OTSession, didFailWithError error: OTError) {
        NSLog("session didFailWithError (%@)", error)
        self.model.isOpenTokConnected.value = false
    }
    
    func session(session: OTSession?, receivedSignalType type: String!, fromConnection connection: OTConnection?, withString string: String!) {
        if connection != nil {
            if (connection?.connectionId != self.session?.connection.connectionId) {
                messagingDelegate?.didRecieveMessage(type, message: string)
            }
        }
    }
    
}

// MARK: - OTSubscriberKitDelegate callbacks
extension GOOpenTokController : OTSubscriberKitDelegate {
    
    func subscriberDidConnectToStream(subscriberKit: OTSubscriberKit) {
        NSLog("subscriberDidConnectToStream (\(subscriberKit))")
        if let view = subscriber?.view {
            if let containerView = self.videoContainerView {
                
                var videoFrame = containerView.frame
                videoFrame.origin.x = 0.0
                videoFrame.origin.y = 0.0
                view.frame =  videoFrame
                containerView.addSubview(view)
                
               self.model.isVideoCallInProgress.value = true
            }
        }
    }
    
    func subscriber(subscriber: OTSubscriberKit, didFailWithError error : OTError) {
        NSLog("subscriber %@ didFailWithError %@", subscriber.stream.streamId, error)
        self.model.isVideoCallInProgress.value = false
    }
    
    func subscriberDidDisconnectFromStream(subscriber: OTSubscriberKit!) {
        self.model.isVideoCallInProgress.value = false
    }
    
    func subscriberVideoDisabled(subscriber: OTSubscriberKit!, reason: OTSubscriberVideoEventReason) {
        self.model.isVideoCallInProgress.value = false
    }
    
    func subscriberVideoEnabled(subscriber: OTSubscriberKit!, reason: OTSubscriberVideoEventReason) {
        self.model.isVideoCallInProgress.value = true
    }
}


// MARK: - OTPublisherDelegate callbacks
extension GOOpenTokController : OTPublisherDelegate {
    
    func publisher(publisher: OTPublisherKit, streamCreated stream: OTStream) {
        NSLog("publisher streamCreated %@", stream)
    }
    
    func publisher(publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        NSLog("publisher streamDestroyed %@", stream)
        
        if subscriber?.stream.streamId == stream.streamId {
            unsubscribe()
        }
    }
    
    func publisher(publisher: OTPublisherKit, didFailWithError error: OTError) {
        NSLog("publisher didFailWithError %@", error)
    }
}

