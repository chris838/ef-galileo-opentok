
import Foundation
import ReactiveCocoa
import CoreMotion
import SwiftyTimer

class GOGalileoVelocityController {
    
    var proportional: Double = 0
    var integral: Double = 0
    var derivative: Double = 0
    var error: Double = 0
    var error_previous: Double = 0
    
    let model: GOModel
    var pidTimer : NSTimer!
    
    init(model:GOModel) {
        self.model = model
        
        // Connect remote touch velocity to Galileo control
        self.model.remoteTouchGestureVelocity.producer.startWithNext { (next:CGPoint) in
            self.model.galileoPanVelocity.value = Double(-next.x)
            self.model.galileoTiltVelocity.value = Double(-next.y)
        }
        
        // Connect remote rotation rate to Galileo pan control
        self.model.remoteRotationRate.producer.startWithNext { (next:CMRotationRate) in
            self.model.galileoPanVelocity.value = Double(-next.x.radiansToDegrees)
        }
        
        // For tilt, we use a PID controller to attempt to minimise the remote-local tilt delta.
        self.pidTimer =  NSTimer.every(self.model.dt.seconds) {

            if self.model.isGalileoConnected.value {
                self.controlLoopTick()
            }
        }
    }
    
    func enableAirGestureControl() {
        
    }
    
    
    func controlLoopTick() {
        
        // Control variables
        let processVariable = tiltAngleFromGravityDegrees(self.model.gravity.value)
        let setpoint = tiltAngleFromGravityMirroredDegrees(self.model.remoteGravity.value)
        
        // Caculate control variable from PID controller
        let controlVariable = determineControlVariablePid(processVariable, setpoint: setpoint)
        
        // Update model with new Galileo tilt velocity
        self.model.galileoTiltVelocity.value = controlVariable
        
    }
    
    func determineControlVariablePid(processVariable:Double, setpoint:Double) -> Double {
        
        let pGain = self.model.pGain
        let iGain = self.model.iGain
        let dGain = self.model.dGain
        let dt = self.model.dt
        
        error_previous = error
        error = setpoint - processVariable
        
        if error > 180 { error -= 360 }
        else if error < -180 {error += 360 }
        
        proportional = error
        integral = integral + (error * dt)
        derivative = (error - error_previous) / dt
        
        if (iGain == 0) {
            return pGain * (proportional + dGain*derivative)
        }
        return pGain * (proportional + (1.0/iGain)*integral + dGain*derivative)
        
    }
    
    func tiltAngleFromGravityDegrees(gravity:CMAcceleration) -> Double {
        
        // Tilt angle of zero equates to neutral tilt position:
        // - Phone screen is exactly perpendicular to the floor
        // - Phone is in "landscape right" orientation
        // - (i.e. home button appears to the right of the screen)
        // - Acute POSITIVE angle means pointing UPWARDS from horizontal
        // - Acute NEGATIVE angle means pointing DOWNWARDS from horizontal
        
        return atan2(gravity.z, -gravity.x).radiansToDegrees
    }
    
    func tiltAngleFromGravityMirroredDegrees(gravity:CMAcceleration) -> Double {
        
        // For the mirror tilt angle, we use the same definition except:
        // - Acute POSITIVE angle means pointing DOWNWARDS from horizontal
        // - Acute NEGATIVE angle means pointing UPWARDS from horizontal
        return atan2(-gravity.z, -gravity.x).radiansToDegrees
    }
}