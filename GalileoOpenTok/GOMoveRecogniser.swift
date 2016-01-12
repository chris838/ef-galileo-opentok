//  Created by Chris Harding on 03/01/2012.
//  Copyright (c) 2012 motrr, LLC. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class GOMoveRecogniser : UIGestureRecognizer {
    
    var minimumNumberOfTouches = 1
    var maximumNumberOfTouches = Int.max
    
    var maxTouchIdlePeriod = 0.1
    
    var initialPosition: CGPoint!
    var previousPosition: CGPoint!
    var latestPosition: CGPoint!
    var previousTimestamp: NSTimeInterval!
    var latestTimestamp: NSTimeInterval!
    
    var timoutTimer: NSTimer?
    
    func translationInView(view: UIView) -> CGPoint {
        if self.isGestureInProgress() {
            let initialPositionInView: CGPoint = self.view!.convertPoint(initialPosition, toView: view)
            let latestPositionInView: CGPoint = self.view!.convertPoint(latestPosition, toView: view)
            return self.subtract(initialPositionInView, fromPoint: latestPositionInView)
        }
        else {
            return CGPointZero
        }
    }
    
    func velocityInView(view: UIView) -> CGPoint {
        if self.isGestureInProgress() {
            let previousPositionInView: CGPoint = self.view!.convertPoint(previousPosition, toView: view)
            let latestPositionInView: CGPoint = self.view!.convertPoint(latestPosition, toView: view)
            let positionDelta: CGPoint = self.subtract(previousPositionInView, fromPoint: latestPositionInView)
            let timeDelta: NSTimeInterval = latestTimestamp - previousTimestamp
            var velocity = CGPoint()
            if timeDelta != 0 {
                velocity.x = positionDelta.x / CGFloat(timeDelta)
                velocity.y = positionDelta.y / CGFloat(timeDelta)
            }
            else {
                velocity = CGPointZero
            }
            return velocity
        }
        else {
            return CGPointZero
        }
    }
    
    func subtract(pointA: CGPoint, fromPoint pointB: CGPoint) -> CGPoint {
        var delta = CGPoint()
        delta.x = pointB.x - pointA.x
        delta.y = pointB.y - pointA.y
        return delta
    }
    
    func isGestureInProgress() -> Bool {
        return (self.state == .Changed)
    }
    
}

// MARK: Interaction with other recognisers
extension GOMoveRecogniser {
    
    
    override func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func canBePreventedByGestureRecognizer(preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}

// MARK: Detecting position & velocity
extension GOMoveRecogniser {
    
    func gestureStarted(touch: UITouch) {
        // Record the position
        initialPosition = touch.locationInView(self.view!)
        // Set this as the latest position also
        latestPosition = touch.locationInView(self.view!)
        latestTimestamp = touch.timestamp
    }
    
    func gestureUpdated(touch: UITouch) {
        // Latest now become previous
        previousPosition = latestPosition
        previousTimestamp = latestTimestamp
        // Get new latest from the incoming touch
        latestPosition = touch.locationInView(self.view!)
        latestTimestamp = touch.timestamp
    }
    
}

// MARK: Touch event handlers
extension GOMoveRecogniser {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Check we are using only one finger
        if (event?.allTouches()?.count <= maximumNumberOfTouches) && (event?.allTouches()?.count >= minimumNumberOfTouches) {
            // If possible, begin the gesture
            if self.state == .Possible {
                self.gestureStarted(event!.allTouches()!.first!)
                self.state = .Began
            }
            else {
                self.finishGesture()
            }
        }
        else {
            self.finishGesture()
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Check we are using only one finger
        if (event?.allTouches()?.count <= maximumNumberOfTouches) && (event?.allTouches()?.count >= minimumNumberOfTouches) {
            // Gesture advances
            if self.state == .Began || self.state == .Changed {
                // Update state given the new touch
                self.gestureUpdated(event!.allTouches()!.first!)
                self.state = .Changed
                // Ensure that update is called again after a specific timeout period, even if no movement occurs
                timoutTimer?.invalidate()
                timoutTimer = NSTimer.scheduledTimerWithTimeInterval(self.maxTouchIdlePeriod, target: self, selector: "touchTimeOut", userInfo: nil, repeats: false)
            }
            else {
                self.finishGesture()
            }
        }
        else {
            self.finishGesture()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.finishGesture()
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        self.finishGesture()
    }
    
    func finishGesture() {
        if self.state == .Began || self.state == .Changed {
            self.state = .Ended
        }
        self.state = .Failed
    }
}

// MARK:  Generating extra updates
extension GOMoveRecogniser {
    
    func touchTimeOut() {
        // Gesture advances
        if self.state == .Began || self.state == .Changed {
            // Update state, movement has basically stopped
            previousPosition = latestPosition
            self.state = .Changed
        }
    }
}
