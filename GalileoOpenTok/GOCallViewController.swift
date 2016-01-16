
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
        updateViewsForCall(true)
        self.controlModeView.hidden = false
        statusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func didStopCall() {
        updateViewsForCall(false)
        self.controlModeView.hidden = true
        statusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
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