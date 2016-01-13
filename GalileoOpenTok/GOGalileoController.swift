
import UIKit
import ReactiveCocoa
import GalileoControl

class GOGalileoController : NSObject {
    
    let model: GOModel
    
    init(model:GOModel) {
        self.model = model
        super.init()
        
        // Observe changes in galileo velocity; forward them to the device
        self.model.galileoPanVelocity.producer.startWithNext { (velocity:Double) in
            if GCGalileo.sharedGalileo().isConnected() {
                GCGalileo.sharedGalileo().velocityControlForAxis(.Pan).targetVelocity = velocity
            }
        }
        self.model.galileoTiltVelocity.producer.startWithNext { (velocity:Double) in
            if GCGalileo.sharedGalileo().isConnected() {
                GCGalileo.sharedGalileo().velocityControlForAxis(.Tilt).targetVelocity = velocity
            }
        }
        
        GCGalileo.sharedGalileo().delegate = self
        GCGalileo.sharedGalileo().waitForConnection()
    }
}

extension GOGalileoController : GCGalileoDelegate {
    
    func galileoDidConnect() {
        print("Connected to Galileo")
        self.model.isGalileoConnected.value = true
    }
    
    func galileoDidDisconnect() {
        print("Disconnected from Galileo!")
        self.model.isGalileoConnected.value = false
        GCGalileo.sharedGalileo().waitForConnection()
    }
    
}