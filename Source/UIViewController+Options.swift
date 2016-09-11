import UIKit

private var CustomOptions = "CustomOptions"
private var DefaultsOptions = "DefaultsOptions"

extension UIViewController {
  
    func registerOptions(options: [String: AnyObject]?) {
        registerOptions(options, defaults: [
                SemiModalOptionKey.TraverseParentHierarchy.rawValue : true,
                SemiModalOptionKey.PushParentBack.rawValue          : false,
                SemiModalOptionKey.AnimationDuration.rawValue       : 0.5,
                SemiModalOptionKey.ParentAlpha.rawValue             : 0.5,
                SemiModalOptionKey.ParentScale.rawValue             : 0.8,
                SemiModalOptionKey.ShadowOpacity.rawValue           : 0.5,
                SemiModalOptionKey.TransitionStyle.rawValue         : SemiModalTransitionStyle.SlideUp.rawValue,
                SemiModalOptionKey.DisableCancel.rawValue           : true
            ])
    }
    
    func registerOptions(options: [String: AnyObject]?, defaults: [String: AnyObject]) {
        objc_setAssociatedObject(self, &CustomOptions, options, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(self, &DefaultsOptions, defaults, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    func optionForKey(optionKey: SemiModalOptionKey) -> AnyObject? {
        let options = objc_getAssociatedObject(self, &CustomOptions) as? [String: AnyObject]
        let defaults = objc_getAssociatedObject(self, &DefaultsOptions) as! [String: AnyObject]
      
        if options?[optionKey.rawValue] != nil {
            return options?[optionKey.rawValue]
        } else {
            return defaults[optionKey.rawValue]
        }
    }

}
