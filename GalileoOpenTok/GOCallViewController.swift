
import UIKit
import ReactiveCocoa

class GOCallViewController: UIViewController {
    
    var viewDidAppearSignal: Signal<(), NoError>!
    private var viewDidAppearObserver: Observer<(), NoError>!
    
    var moveRecogniserSignal: Signal<GOMoveRecogniser, NoError>!
    private var moveRecogniserObserver: Observer<GOMoveRecogniser, NoError>!
    
    var doubleTabSignal: Signal<(), NoError>!
    private var doubleTabObserver: Observer<(), NoError>!
    
    var moveRecogniser: GOMoveRecogniser!
    var doubleTapRecogniser: UITapGestureRecognizer!
    var statusBarHidden:Bool = false

    @IBOutlet weak var controlModeContainerView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var controlModeLabel: UILabel!
    @IBOutlet weak var openTokStatusLabel: UILabel!
    @IBOutlet weak var galileoStatusLabel: UILabel!
    @IBOutlet weak var controlModeView: UIView!
    
    var mainController: GOMainController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupMoveRecogniser()
        self.setupDoubleTapRecogniser()
        self.setupViewDidAppearSignal()

        mainController = GOMainController(callViewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.viewDidAppearObserver?.sendNext(())
    }
    
    func setupViewDidAppearSignal() {
        let (signal, observer) = Signal<(), NoError>.pipe()
        self.viewDidAppearSignal = signal
        self.viewDidAppearObserver = observer
    }

    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}


// MARK: - Move recogniser
extension GOCallViewController {
    
    func setupMoveRecogniser() {
        
        let (signal, observer) = Signal<GOMoveRecogniser, NoError>.pipe()
        self.moveRecogniserSignal = signal
        self.moveRecogniserObserver = observer
        
        moveRecogniser = GOMoveRecogniser(target: self, action: Selector("moveRecogniserHandler:"))
        self.videoContainerView.addGestureRecognizer(moveRecogniser)
    }
    
    func moveRecogniserHandler(mr:GOMoveRecogniser) {
        self.moveRecogniserObserver.sendNext(mr)
    }
}


// MARK: - Double tap recogniser
extension GOCallViewController {
    
    func setupDoubleTapRecogniser() {
        
        let (signal, observer) = Signal<(), NoError>.pipe()
        self.doubleTabSignal = signal
        self.doubleTabObserver = observer
        
        doubleTapRecogniser = UITapGestureRecognizer(target: self, action: Selector("doubleTapHandler"))
        doubleTapRecogniser.numberOfTapsRequired = 2
        self.videoContainerView.addGestureRecognizer(doubleTapRecogniser)
    }
    
    func doubleTapHandler() {
        self.doubleTabObserver.sendNext()
    }
}

// MARK: - Update view for call in progress / not in progress
extension GOCallViewController {
    
    func didStartCall() {
        self.controlModeView.hidden = false
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .AllowUserInteraction, animations: {
            
            self.updateViewsForCall(true)
            self.statusBarHidden = true
            self.setNeedsStatusBarAppearanceUpdate()

            }) { _ in}
    }
    
    func didStopCall() {
        self.controlModeView.hidden = true
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .AllowUserInteraction, animations: {
            
            self.updateViewsForCall(false)
            self.statusBarHidden = false
            self.setNeedsStatusBarAppearanceUpdate()

            }) { _ in}
    }
    
    func updateViewsForCall(inProgress:Bool) {
        
        let inProgressAlpha = CGFloat(inProgress)
        
        for view in [videoContainerView] {
            view.alpha = inProgressAlpha
        }
        
        for view in [openTokStatusLabel, galileoStatusLabel] {
            view.alpha = 1.0 - inProgressAlpha
        }
    }
}


// MARK: - Update view for control mode
extension GOCallViewController {
    
    func didSwitchToMotionControl() {
        self.controlModeLabel.text = "MOTION CONTROL: ENABLED"
        self.flashControlMode()
    }
    
    func didSwitchToTouchControl() {
        self.controlModeLabel.text = "TOUCH CONTROL: ENABLED"
        self.flashControlMode()
    }
    
    func flashControlMode() {
        self.controlModeView.alpha = 1.0
        UIView.animateWithDuration(0.5, delay: 1.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .AllowUserInteraction, animations: {
                self.controlModeView.alpha = 0.0
            }) { _ in}
    }
}