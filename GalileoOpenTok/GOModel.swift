//  Created by Chris Harding on 1/12/16.
//  Copyright © 2016 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import CoreMotion
import ReactiveCocoa

class GOModel {
    /*
    var orientation = MutableProperty<CMAttitude?>(nil)
    var remoteOrientation = MutableProperty<CMAttitude?>(nil)
    
    var rotationRate = MutableProperty<CMRotationRate?>(nil)
    var remoteRotationRate = MutableProperty<CMRotationRate?>(nil)
    */
    var touchGestureVelocity = MutableProperty<CGPoint>(CGPoint(x: 0, y: 0))
    var remoteTouchGestureVelocity = MutableProperty<CGPoint>(CGPoint(x: 0, y: 0))
    
}
