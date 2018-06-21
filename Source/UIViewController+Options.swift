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
        objc_setAssociatedObject(self, &CustomOptions, options, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    func optionForKey(_ optionKey: SemiModalOption) -> Any? {
        let options = objc_getAssociatedObject(self, &CustomOptions) as? [SemiModalOption: Any]
      
        if options?[optionKey] != nil {
            return options?[optionKey]
        } else {
            return defaultOptions[optionKey]
        }
    }

}
