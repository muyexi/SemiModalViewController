import UIKit

extension UIDevice {
    
    static func isPad() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
}