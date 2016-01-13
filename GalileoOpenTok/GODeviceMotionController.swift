
import Foundation
import CoreMotion

class GODeviceMotionController {
    
    let model: GOModel
    let manager: CMMotionManager
    
    init(model:GOModel) {
        
        self.model = model
        manager = CMMotionManager()
        
        // Start listening for motion updates
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.2
            manager.startDeviceMotionUpdatesUsingReferenceFrame(.XArbitraryCorrectedZVertical, toQueue: NSOperationQueue.mainQueue()) {(motion:CMDeviceMotion?, error:NSError?) in
                if motion != nil {
                    self.model.gravity.value = motion!.gravity
                    self.model.rotationRate.value = motion!.rotationRate
                }
                else {
                    print("No motion available")
                    print(error)
                }
            }
        }
    }
 }

