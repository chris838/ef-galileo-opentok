
import Foundation
import ReactiveCocoa

class GOMainController {
    
    // Model
    var model: GOModel
    
    // UI
    var callViewController: GOCallViewController
    
    // Controller
    var openTokController: GOOpenTokController
    var messagingController: GOMessagingController
    var touchGestureController: GOTouchGestureController
    var galileoController: GOGalileoController
    var deviceMotionController: GODeviceMotionController
    
    init(callViewController:GOCallViewController) {
        
        UIApplication.sharedApplication().idleTimerDisabled = true

        // Initilise model
        self.model = GOModel()

        // Initialise UI
        self.callViewController = callViewController
        
        // Innitialise controllers
        self.openTokController = GOOpenTokController(model: model)
        self.messagingController = GOMessagingController(model: model, openTokController: self.openTokController)
        self.touchGestureController = GOTouchGestureController(model: model)
        self.galileoController = GOGalileoController(model: model)
        self.deviceMotionController = GODeviceMotionController(model: model)
        
        // Connect OpenTok video to UI
        self.openTokController.videoContainerView = self.callViewController.videoContainerView
        
        // Connect to OpenTok whenever call view appears
        self.callViewController.viewDidAppearSignal.observeNext {
            self.openTokController.connect()
        }
        
        // Update UI based on OpenTok status
        self.model.isOpenTokConnected.producer.startWithNext { (next:Bool) in
            if (next) {
                self.callViewController.openTokStatusLabel.text = "OpenTok is connected"
            }
            else {
                self.callViewController.openTokStatusLabel.text = "OpenTok is disconnected"
            }
        }
        self.model.isVideoCallInProgress.producer.startWithNext { (next:Bool) in
            if (next) { self.callViewController.didStartCall() }
            else { self.callViewController.didStopCall() }
        }
        
        // Update UI based on Galileo connection status
        self.model.isGalileoConnected.producer.startWithNext { (next:Bool) in
            if (next) {
                self.callViewController.galileoStatusLabel.text = "Galileo is connected."
            }
            else {
                self.callViewController.galileoStatusLabel.text = "Galileo is disconnected."
            }
        }
        
        // Generate UIAlertViews from tokbox error signal
        self.openTokController.errorSignal.observeNext { (next:String) in
            let alertController = UIAlertController(title: "OpenTok Error", message: next, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { _ in}
            alertController.addAction(OKAction)
            self.callViewController.presentViewController(alertController, animated: true) {}
        }
        
        // Forward gesture events to the touch control controller
        self.callViewController.moveRecogniserSignal.observe(self.touchGestureController.touchEventObserver)
        
        // Connect remote touch velocity to Galileo control
        self.model.remoteTouchGestureVelocity.producer.startWithNext { (next:CGPoint) in
            self.model.galileoPanVelocity.value = Double(-next.x)
            self.model.galileoTiltVelocity.value = Double(-next.y)
        }
        
    }
}