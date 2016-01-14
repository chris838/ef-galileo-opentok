
import Foundation
import ReactiveCocoa
import CoreMotion
import SwiftyTimer

class GOAirGestureController {
    
    let pGain:Double = 0
    let iGain:Double = 0
    let dGain:Double = 0
    
    var proportional: Double = 0
    var integral: Double = 0
    var derivative: Double = 0
    
    var dt: Double = 0.05
    
    var error: Double = 0
    var error_previous: Double = 0
    
    let model: GOModel
    
    var pidTimer : NSTimer!
    
    
    init(model:GOModel) {
        self.model = model
        
        // Connect remote rotation rate to Galileo pan control
        /*
        self.model.remoteRotationRate.producer.startWithNext { (next:CMRotationRate) in
            self.model.galileoPanVelocity.value = Double(next.x.radiansToDegrees)
        }
        */
        
        // For tilt, we use a PID controller to attempt to minimise the remote-local tilt delta.
        self.pidTimer =  NSTimer.every(dt.seconds) {
            if self.model.isGalileoConnected.value {
                self.controlLoopTick()
            }
        }
    }
    
    
    func controlLoopTick() {
        
        // Load variables from model
        let processVariable = tiltAngleFromGravity(self.model.gravity.value)
        let setpoint = tiltAngleFromGravity(self.model.remoteGravity.value)
        
        // Caculate control variable from PID controller
        let controlVariable = determineControlVariablePid(processVariable, setpoint: setpoint)
        
        // Update model with new Galileo tilt velocity
        self.model.galileoTiltVelocity.value = controlVariable
        
    }
    
    func determineControlVariablePid(processVariable:Double, setpoint:Double) -> Double {
        
        error_previous = error
        error = setpoint - processVariable
        
        proportional = error
        integral = integral + (error * dt)
        derivative = (error - error_previous) / dt
        
        if (iGain == 0) {
            return pGain * (proportional + dGain*derivative)
        }
        return pGain * (proportional + (1.0/iGain)*integral + dGain*derivative)
        
    }
    
    func tiltAngleFromGravity(gravity:CMAcceleration) -> Double {
        
        // Tilt angle of zero equates to neutral tilt position:
        // - Phone screen is exactly perpendicular to the floor
        // - Phone is in "landscape right" orientation
        // - (i.e. home button appears to the right of the screen)
        
        return atan2(gravity.z, -gravity.x).radiansToDegrees
    }
    
}