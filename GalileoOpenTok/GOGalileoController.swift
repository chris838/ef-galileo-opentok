
import UIKit
import ReactiveCocoa
import GalileoControl

class GOGalileoController : NSObject {

    let minVelocityThreshold = 2.0
    
    let model: GOModel
    
    init(model:GOModel) {
        self.model = model
        super.init()
        
        // Observe changes in galileo velocity; forward them to the device
        self.model.galileoPanVelocity.producer.startWithNext { (velocity:Double) in
            self.setTargetVelocity(velocity, axis: .Pan)
        }
        self.model.galileoTiltVelocity.producer.startWithNext { (velocity:Double) in
            self.setTargetVelocity(velocity, axis: .Tilt)
        }
        
        GCGalileo.sharedGalileo().delegate = self
        GCGalileo.sharedGalileo().waitForConnection()
        // GCGalileo.sharedGalileo().logLevel = .Info
    }
    
    func setTargetVelocity(var velocity:Double, axis:GCControlAxis) {
        if GCGalileo.sharedGalileo().isConnected() {
            if abs(velocity) <  minVelocityThreshold { velocity = 0}
            GCGalileo.sharedGalileo().velocityControlForAxis(axis).targetVelocity = velocity
        }
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