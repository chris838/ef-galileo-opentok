
import UIKit
import ReactiveCocoa
import GalileoControl

class GOGalileoController : NSObject {
    
    override init() {
        super.init()
        GCGalileo.sharedGalileo().delegate = self
        GCGalileo.sharedGalileo().waitForConnection()
        
    }
    
    func updatePanVelocity(velocity:Double) {
        if GCGalileo.sharedGalileo().isConnected() {
            GCGalileo.sharedGalileo().velocityControlForAxis(.Pan).targetVelocity = velocity
        }
    }
    
    func updateTiltVelocity(velocity:Double) {
        if GCGalileo.sharedGalileo().isConnected() {
            GCGalileo.sharedGalileo().velocityControlForAxis(.Tilt).targetVelocity = velocity
        }
    }
}

extension GOGalileoController : GCGalileoDelegate {
    
    func galileoDidConnect() {
        print("Connected to Galileo")
    }
    
    func galileoDidDisconnect() {
        print("Disconnected from Galileo!")
        GCGalileo.sharedGalileo().waitForConnection()
    }
    
}