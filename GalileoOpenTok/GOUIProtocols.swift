//  Created by Chris Harding on 22/11/2014.
//  Copyright (c) 2014 Motrr. All rights reserved.
//

import UIKit

/*
These protocols are used throughout the UI layer. They qualify how non-UI controller objects should interact with the UI layer.
*/

// Call these responders when sending messages TO the UI layer.

@objc protocol GOUIResponder {}

@objc protocol GOCallStatusResponder {
    func didStartCall()
    func didStopCall()
}