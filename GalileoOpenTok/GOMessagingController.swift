
import Foundation
import ReactiveCocoa
import CoreMotion

enum GOMessageType : String {
    case TouchGestureVelocity
    case Gravity
    case RotationRate
    case ControlMode
}

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
            self.sendMessage(.TouchGestureVelocity, message: serialisedValue)
        }
        
        self.model.gravity.producer.startWithNext { (next:CMAcceleration) in
            let serialisedValue = "\(next.x);\(next.y);\(next.z)"
            self.sendMessage(.Gravity, message: serialisedValue)
        }
        
        self.model.rotationRate.producer.startWithNext { (next:CMRotationRate) in
            let serialisedValue = "\(next.x);\(next.y);\(next.z)"
            self.sendMessage(.RotationRate, message: serialisedValue)
        }
        
        self.model.controlMode.producer.startWithNext { (next:GOControlMode) in
            self.sendMessage(.ControlMode, message: next.rawValue)
        }
    }
    
    func sendMessage(type:GOMessageType, message:String) {
        self.openTokController.session?.signalWithType(type.rawValue, string: message, connection: nil, error:nil)
    }
}

extension GOMessagingController : GOOpenTokControllerMessagingDelegate {
    
    /* Parse incoming messages from remote to update local state
    */
    
    func didRecieveMessage(messageTypeString: String, message: String) {
        
        // Parse message, then update properties in model regarding remote state
        if let messageType : GOMessageType = GOMessageType(rawValue: messageTypeString) {
            switch messageType {
            case .TouchGestureVelocity:
                parseRemoteTouchGestureVelocityUpdate(message)
            case .Gravity:
                parseRemoteGravityUpdate(message)
            case .RotationRate:
                parseRemoteRotationRateUpdate(message)
            case .ControlMode:
                parseRemoteControlModeUpdate(message)
            }
        } else { print("Error, recieved unknown message type") }
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
    
    func parseRemoteControlModeUpdate(message:String) {
        self.model.remoteControlMode.value = GOControlMode(rawValue: message)!
    }

}
