
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
    var touchControlController: GOTouchControlController
    var galileoController: GOGalileoController
    
    init(callViewController:GOCallViewController) {
        
        UIApplication.sharedApplication().idleTimerDisabled = true

        // Initilise model
        self.model = GOModel()

        // Initialise UI
        self.callViewController = callViewController
        
        // Innitialise controller
        self.openTokController = GOOpenTokController()
        self.messagingController = GOMessagingController(model: model, openTokController: self.openTokController)
        self.touchControlController = GOTouchControlController(model: model)
        self.galileoController = GOGalileoController()
        
        // Connect OpenTok video to UI
        self.openTokController.videoContainerView = self.callViewController.videoContainerView
        
        // Connect to OpenTok whenever call view appears
        self.callViewController.viewDidAppearSignal.observeNext {
            self.openTokController.connect()
        }
        
        // Update UI based on call status
        self.openTokController.statusSignal.observeNext { (next:GOOpenTokCallStatus) in
            switch next {
            case .VideoInProgress: self.callViewController.didStartCall()
            default: self.callViewController.didStopCall()
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
        self.callViewController.moveRecogniserSignal.observe(self.touchControlController.touchEventObserver)
        
        // Connect remote touch velocity to Galileo control
        self.model.remoteTouchGestureVelocity.producer.startWithNext { (next:CGPoint) in
            self.galileoController.updatePanVelocity(Double(-next.x))
            self.galileoController.updateTiltVelocity(Double(-next.y))
        }

        
        
    }
}