import UIKit

private var CustomOptions = "CustomOptions"
private var DefaultsOptions = "DefaultsOptions"

extension UIViewController {
  
    func registerOptions(_ options: [String: Any]?) {
        registerOptions(options, defaults: [
                SemiModalOption.traverseParentHierarchy.rawValue : true,
                SemiModalOption.pushParentBack.rawValue          : false,
                SemiModalOption.animationDuration.rawValue       : 0.5,
                SemiModalOption.parentAlpha.rawValue             : 0.5,
                SemiModalOption.parentScale.rawValue             : 0.8,
                SemiModalOption.shadowOpacity.rawValue           : 0.5,
                SemiModalOption.transitionStyle.rawValue         : SemiModalTransitionStyle.slideUp.rawValue,
                SemiModalOption.disableCancel.rawValue           : true
            ])
    }
    
    func registerOptions(_ options: [String: Any]?, defaults: [String: Any]) {
        objc_setAssociatedObject(self, &CustomOptions, options, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(self, &DefaultsOptions, defaults, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    func optionForKey(_ optionKey: SemiModalOption) -> Any? {
        let options = objc_getAssociatedObject(self, &CustomOptions) as? [String: Any]
        let defaults = objc_getAssociatedObject(self, &DefaultsOptions) as! [String: Any]
      
        if options?[optionKey.rawValue] != nil {
            return options?[optionKey.rawValue]
        } else {
            return defaults[optionKey.rawValue]
        }
    }

}
