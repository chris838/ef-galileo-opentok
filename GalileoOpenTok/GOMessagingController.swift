
import Foundation
import ReactiveCocoa
import CoreMotion

class GOMessagingController {
    
    let model: GOModel
    let openTokController: GOOpenTokController
    
    init(model:GOModel, openTokController:GOOpenTokController) {
        
        self.model = model
        self.openTokController = openTokController
        self.openTokController.messagingDelegate = self
        
        /* Observe local model properties and generate messages to update remote state
        */
        
        self.model.touchGestureVelocity.producer.startWithNext { (next:CGPoint) in
            let serialisedValue = "\(next.x);\(next.y)"
            self.openTokController.session?.signalWithType("touchGestureVelocity", string: serialisedValue, connection: nil,  error:nil)
        }
        
        self.model.gravity.producer.startWithNext { (next:CMAcceleration) in
            let serialisedValue = "\(next.x);\(next.y);\(next.z)"
            self.openTokController.session?.signalWithType("gravity", string: serialisedValue, connection: nil, error:nil)
        }
        
        self.model.rotationRate.producer.startWithNext { (next:CMRotationRate) in
            let serialisedValue = "\(next.x);\(next.y);\(next.z)"
            self.openTokController.session?.signalWithType("rotationRate", string: serialisedValue, connection: nil, error:nil)
        }
    }
}

extension GOMessagingController : GOOpenTokControllerMessagingDelegate {
    
    /* Parse incoming messages from remote to update local state
    */
    
    func didRecieveMessage(messageType: String, message: String) {
        
        // Parse message, then update properties in model regarding remote state
        switch messageType {
        case "touchGestureVelocity":
            parseRemoteTouchGestureVelocityUpdate(message)
        case "gravity":
            parseRemoteGravityUpdate(message)
        case "rotationRate":
            parseRemoteRotationRateUpdate(message)
        default:
            print("Error, recieved unknown message type")
        }
    }
    
    func parseRemoteTouchGestureVelocityUpdate(message:String) {
        let messageArray = message.componentsSeparatedByString(";")
        let deserialisedValue = CGPoint(x: Double(messageArray[0])!, y: Double(messageArray[1])!)
        self.model.remoteTouchGestureVelocity.value = deserialisedValue
    }
    
    func parseRemoteGravityUpdate(message:String) {
        let messageArray = message.componentsSeparatedByString(";")
        let deserialisedValue = CMAcceleration(x: Double(messageArray[0])!, y: Double(messageArray[1])!, z: Double(messageArray[2])!)
        self.model.remoteGravity.value = deserialisedValue
    }
    
    func parseRemoteRotationRateUpdate(message:String) {
        let messageArray = message.componentsSeparatedByString(";")
        let deserialisedValue = CMRotationRate(x: Double(messageArray[0])!, y: Double(messageArray[1])!, z: Double(messageArray[2])!)
        self.model.remoteRotationRate.value = deserialisedValue
    }

}
