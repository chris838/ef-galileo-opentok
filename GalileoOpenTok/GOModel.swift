//  Created by Chris Harding on 1/12/16.
//  Copyright © 2016 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import CoreMotion
import ReactiveCocoa

class GOModel {

    var gravity = MutableProperty<CMAcceleration>(CMAcceleration(x: 0, y: 0, z: 0))
    var remoteGravity = MutableProperty<CMAcceleration>(CMAcceleration(x: 0, y: 0, z: 0))

    var rotationRate = MutableProperty<CMRotationRate>(CMRotationRate(x: 0, y: 0, z: 0))
    var remoteRotationRate = MutableProperty<CMRotationRate>(CMRotationRate(x: 0, y: 0, z: 0))

    var touchGestureVelocity = MutableProperty<CGPoint>(CGPoint(x: 0, y: 0))
    var remoteTouchGestureVelocity = MutableProperty<CGPoint>(CGPoint(x: 0, y: 0))
    
    var isGalileoConnected = MutableProperty<Bool>(false)
    var isOpenTokConnected = MutableProperty<Bool>(false)
    var isVideoCallInProgress = MutableProperty<Bool>(false)
    
    var galileoPanVelocity = MutableProperty<Double>(0)
    var galileoTiltVelocity = MutableProperty<Double>(0)    
}
