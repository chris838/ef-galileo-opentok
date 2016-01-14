
import Foundation
import ReactiveCocoa
import CoreMotion
import SwiftyTimer

class GOAirGestureController {
    
    var proportional: Double = 0
    var integral: Double = 0
    var derivative: Double = 0
    
    var dt: Double = 0.05
    
    var error: Double = 0
    var error_previous: Double = 0
    
    var pidTimer : NSTimer!
    
    let model: GOModel
    
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
        
        let pGain = self.model.remotePGain.value
        let iGain = self.model.remoteIGain.value
        let dGain = self.model.remoteDGain.value

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
    
    func determineControlVariableSimple(processVariable:Double, setpoint:Double) -> Double {
        
        error_previous = error
        error = setpoint - processVariable

        let deadband = 5.0
        let max_velocity = 180.0
        
        let error_sign: Double = (error > 0 ? 1 : -1)
        
        var output_velocity = error_sign
        if abs(error) < deadband {
            output_velocity *= 0
        }
        else {
            output_velocity *= max_velocity
        }
        
        return output_velocity
        
    }
    
    func tiltAngleFromGravity(gravity:CMAcceleration) -> Double {
        
        // Tilt angle of zero equates to neutral tilt position:
        // - Phone screen is exactly perpendicular to the floor
        // - Phone is in "landscape right" orientation
        // - (i.e. home button appears to the right of the screen)
        
        return atan2(gravity.z, -gravity.x).radiansToDegrees
    }
    
}