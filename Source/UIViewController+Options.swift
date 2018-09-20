import UIKit

private var CustomOptions: Void?

extension UIViewController {
    
    var defaultOptions: [SemiModalOption: Any] {
        return [
            .traverseParentHierarchy : true,
            .pushParentBack          : false,
            .animationDuration       : 0.5,
            .parentAlpha             : 0.5,
            .parentScale             : 0.8,
            .shadowOpacity           : 0.5,
            .transitionStyle         : SemiModalTransitionStyle.slideUp,
            .disableCancel           : true
        ]
    }
  
    func registerOptions(_ options: [SemiModalOption: Any]?) {
        // options always save in parent viewController
        var targetVC: UIViewController = self
        while targetVC.parent != nil {
            targetVC = targetVC.parent!
        }
        
        objc_setAssociatedObject(targetVC, &CustomOptions, options, .OBJC_ASSOCIATION_RETAIN)
    }
    
    func options() -> [SemiModalOption: Any] {
        var targetVC: UIViewController = self
        while targetVC.parent != nil {
            targetVC = targetVC.parent!
        }
        
        if let options = objc_getAssociatedObject(targetVC, &CustomOptions) as? [SemiModalOption: Any] {
            var defaultOptions: [SemiModalOption: Any] = self.defaultOptions
            defaultOptions.merge(options) { (_, new) in new }
            
            return defaultOptions
        } else {
            return defaultOptions
        }
    }
    
    func optionForKey(_ optionKey: SemiModalOption) -> Any? {
        let options = self.options()
        let value = options[optionKey]
        
        let isValidType = value is Bool ||
            value is Double ||
            value is SemiModalTransitionStyle ||
            value is UIView
        
        if isValidType {
            return value
        } else {
            return defaultOptions[optionKey]
        }
    }

}
