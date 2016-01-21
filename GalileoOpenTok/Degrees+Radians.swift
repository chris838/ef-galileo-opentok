
import Foundation

extension Int {
    var degreesToRadians : Double {
        return Double(self).degreesToRadians
    }
}
extension CGFloat {
    var degreesToRadians : Double {
        return Double(self).degreesToRadians
    }
}
extension Double {
    var degreesToRadians : Double {
        return self * M_PI / 180.0
    }
}


extension Int {
    var radiansToDegrees : Double {
        return Double(self).degreesToRadians
    }
}
extension CGFloat {
    var radiansToDegrees : Double {
        return Double(self).degreesToRadians
    }
}
extension Double {
    var radiansToDegrees : Double {
        return self * 180.0 / Double(M_PI)
    }
}

