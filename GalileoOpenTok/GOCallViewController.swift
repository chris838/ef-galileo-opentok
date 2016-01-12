
import UIKit
import ReactiveCocoa

class GOCallViewController: UIViewController {
    
    var viewDidAppearSignal: Signal<(), NoError>!
    private var viewDidAppearObserver: Observer<(), NoError>!
    
    var moveRecogniserSignal: Signal<GOMoveRecogniser, NoError>!
    private var moveRecogniserObserver: Observer<GOMoveRecogniser, NoError>!
    
    var moveRecognizer: GOMoveRecogniser!
    var statusBarHidden:Bool = false

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var openTokStatusLabel: UILabel!
    @IBOutlet weak var galileoStatusLabel: UILabel!
    
    var mainController: GOMainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMoveRecogniser()
        
        if viewDidAppearSignal == nil {
            let (signal, observer) = Signal<(), NoError>.pipe()
            self.viewDidAppearSignal = signal
            self.viewDidAppearObserver = observer
        }

        if moveRecogniserSignal == nil {
            let (signal2, observer2) = Signal<GOMoveRecogniser, NoError>.pipe()
            self.moveRecogniserSignal = signal2
            self.moveRecogniserObserver = observer2
        }
        
        mainController = GOMainController(callViewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.viewDidAppearObserver?.sendNext(())
    }
    
    func setupMoveRecogniser() {
        moveRecognizer = GOMoveRecogniser(target: self, action: Selector("moveRecogniserHandler:"))
        self.videoContainerView.addGestureRecognizer(moveRecognizer)
    }
    
    func moveRecogniserHandler(mr:GOMoveRecogniser) {
        self.moveRecogniserObserver.sendNext(mr)
    }

    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
}

extension GOCallViewController : GOCallStatusResponder {
    
    func didStartCall() {
        updateViewsForCall(true)
        statusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func didStopCall() {
        updateViewsForCall(false)
        statusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func updateViewsForCall(inProgress:Bool) {
        for view in [roleLabel, openTokStatusLabel, galileoStatusLabel] {
            view.hidden = inProgress
        }
    }
}