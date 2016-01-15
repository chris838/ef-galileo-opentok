//  Created by Chris Harding on 1/12/16.
//  Copyright © 2016 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import CoreMotion
import ReactiveCocoa

enum GOControlMode: String {
    case TouchGestureControl
    case AirGestureControl
}

class GOModel {
    
    // MARK: - Kinematic state

    var gravity = MutableProperty<CMAcceleration>(CMAcceleration(x: 0, y: 0, z: 0))
    var remoteGravity = MutableProperty<CMAcceleration>(CMAcceleration(x: 0, y: 0, z: 0))

    var rotationRate = MutableProperty<CMRotationRate>(CMRotationRate(x: 0, y: 0, z: 0))
    var remoteRotationRate = MutableProperty<CMRotationRate>(CMRotationRate(x: 0, y: 0, z: 0))

    var touchGestureVelocity = MutableProperty<CGPoint>(CGPoint(x: 0, y: 0))
    var remoteTouchGestureVelocity = MutableProperty<CGPoint>(CGPoint(x: 0, y: 0))
    
    
    // MARK: - Galileo config
    
    var isGalileoConnected = MutableProperty<Bool>(false)
    var galileoPanVelocity = MutableProperty<Double>(0)
    var galileoTiltVelocity = MutableProperty<Double>(0)
    
    
    // MARK: - Galileo velocity control config
    
    var controlMode = MutableProperty<GOControlMode>(.TouchGestureControl)
    var remoteControlMode = MutableProperty<GOControlMode>(.TouchGestureControl)
    
    let dt: Double = 0.1
    let pGain:Double = 2.3
    let iGain:Double = 0
    let dGain:Double = 0
    

    // MARK: - OpenTok/Video config
    
    var isOpenTokConnected = MutableProperty<Bool>(false)
    var isVideoCallInProgress = MutableProperty<Bool>(false)
    
    // API details available here: https://dashboard.tokbox.com/projects
    let apiKey = "45464132"
    let sessionId = "1_MX40NTQ2NDEzMn5-MTQ1MjYwNDQzNTg4OX4wYkdwNm5WQTFDbjBVQ05KUUNBN0kvQUN-UH4"
    let token = "T1==cGFydG5lcl9pZD00NTQ2NDEzMiZzaWc9MDQ4YmNlNWU1ZDIwOWRjNGNmZTFkMTgyMmQzNzU5ZTU3NmUxY2NkZDpyb2xlPXB1Ymxpc2hlciZzZXNzaW9uX2lkPTFfTVg0ME5UUTJOREV6TW41LU1UUTFNall3TkRRek5UZzRPWDR3WWtkd05tNVdRVEZEYmpCVlEwNUtVVU5CTjBrdlFVTi1VSDQmY3JlYXRlX3RpbWU9MTQ1MjYwNDQ0MSZub25jZT0wLjM3NTExODU3MDc3NzA5ODImZXhwaXJlX3RpbWU9MTQ1NTE5NjM3MSZjb25uZWN0aW9uX2RhdGE9"
}
