import UIKit

extension UIView {

    func containingViewController() -> UIViewController {
        let target = (superview != nil) ? superview : self
        return target!.traverseResponderChainForUIViewController() as! UIViewController
    }
  
    func traverseResponderChainForUIViewController() -> AnyObject? {
        let nextResponder: UIResponder = self.next!
        
        let isViewController = nextResponder is UIViewController
        let isTabBarController = nextResponder is UITabBarController
        
        if isViewController && !isTabBarController {
          return nextResponder
        } else if isTabBarController {
          return (nextResponder as! UITabBarController).selectedViewController!
        } else if nextResponder is UIView {
          return (nextResponder as! UIView).traverseResponderChainForUIViewController()
        } else {
          return nil
        }
    }
  
}
