
import UIKit
import ReactiveCocoa

class GOTouchControlController {
    
    let trackpadSensitivity: CGFloat = 5
    let iPhoneWidthMM: CGFloat = 75.0
    let iPadMiniWidthMM: CGFloat = 160.0
    let iPadWidthMM: CGFloat = 198.0
    
    // Sink for incoming touch events
    private let touchEventSignal: Signal<GOMoveRecogniser, NoError>
    let touchEventObserver: Observer<GOMoveRecogniser, NoError>
    
    let model: GOModel
    
    init(model:GOModel) {
       self.model = model
        
        let (signal, observer) = Signal<GOMoveRecogniser, NoError>.pipe()
        touchEventSignal = signal
        touchEventObserver = observer
        
        touchEventSignal.observeNext { (next:GOMoveRecogniser) -> () in
            switch next.state {
            case .Began, .Changed:
                
                let velocity = next.velocityInView(next.view!)
                
                // Scale according to physical screen dimensions
                var px = velocity.y * (self.iPhoneWidthMM / self.iPadMiniWidthMM);
                var py = -velocity.x * (self.iPhoneWidthMM / self.iPadMiniWidthMM);
                
                // Apply sensitivity scaling
                px = (self.trackpadSensitivity*px) / 35;
                py = (self.trackpadSensitivity*py) / 35;
                
                // Truncate to correct range
                px = max(min(px, 100), -100)
                py = max(min(py, 100), -100)
                
                self.model.touchGestureVelocity.value = CGPoint(x: py, y: -px)
                
            default:
                self.model.touchGestureVelocity.value = CGPoint(x: 0, y: 0)

            }
        }
    }
    
}