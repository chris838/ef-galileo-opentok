
import Foundation
import ReactiveCocoa

class GOMessagingController {
    
    let model: GOModel
    let openTokController: GOOpenTokController
    
    init(model:GOModel, openTokController:GOOpenTokController) {
        
        self.model = model
        self.openTokController = openTokController
        self.openTokController.messagingDelegate = self
        
        // Observe local model properties, generate message to update remote state
        
        self.model.touchGestureVelocity.producer.startWithNext { (next:CGPoint) in
            let serialisedValue = "\(next.x);\(next.y)"
            self.openTokController.session?.signalWithType("touchGestureVelocity", string: serialisedValue, connection: nil, retryAfterReconnect: false, error:nil)
        }
    }
    
}

extension GOMessagingController : GOOpenTokControllerMessagingDelegate {
    
    func didRecieveMessage(messageType: String, message: String) {
        
        // Parse message, then update properties in model regarding remote state
        switch messageType {
        case "touchGestureVelocity":
            parseRemoteTouchGestureVelocityUpdate(message)
            
        default:
            print("Error, recieved unknown message type")
        }
    }
    
    func parseRemoteTouchGestureVelocityUpdate(message:String) {
        
        let messageArray = message.componentsSeparatedByString(";")
        let deserialisedValue = CGPoint(x: Double(messageArray[0])!, y: Double(messageArray[1])!)
        self.model.remoteTouchGestureVelocity.value = deserialisedValue
    }
    

}
