
import Foundation
import ReactiveCocoa

class GOMainController {
    
    var callViewController : GOCallViewController
    var openTokController : GOOpenTokController
    
    init(callViewController:GOCallViewController) {
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        self.callViewController = callViewController
        self.openTokController = GOOpenTokController()
        
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
        
        // TODO - generate UIAlertViews from tokbox error signal
    }
    
    
}