import UIKit
   
private let semiModalDidShowNotification = "semiModalDidShowNotification"
private let semiModalDidHideNotification = "semiModalDidHideNotification"
private let semiModalWasResizedNotification = "semiModalWasResizedNotification"

private var semiModalViewController = "PaPQC93kjgzUanz"
private var semiModalDismissBlock = "PaPQC93kjgzUanz"
private var semiModalPresentingViewController = "PaPQC93kjgzUanz"

private let semiModalOverlayTag = 10001
private let semiModalScreenshotTag = 10002
private let semiModalModalViewTag = 10003
private let semiModalDismissButtonTag = 10004

public enum SemiModalOptionKey: String {
    case TraverseParentHierarchy
    case PushParentBack
    case AnimationDuration
    case ParentAlpha
    case ParentScale
    case ShadowOpacity
    case TransitionStyle
    case DisableCancel
    case BackgroundView
}

public enum SemiModalTransitionStyle: String {
   case SlideUp
   case FadeInOut
   case FadeIn
   case FadeOut
}

extension UIViewController {
 
    public func presentSemiViewController(vc: UIViewController) {
        presentSemiViewController(vc, options: nil, completion: nil, dismissBlock: nil)
    }
    
    public func presentSemiViewController(vc: UIViewController, options: [String: AnyObject]?) {
        presentSemiViewController(vc, options: nil, completion: nil, dismissBlock: nil)
    }
    
    public func presentSemiViewController(vc: UIViewController,
                                   options: [String: AnyObject]?,
                                   completion: (() -> Void)?,
                                   dismissBlock: (() -> Void)?) {
        registerOptions(options)
        let targetParentVC = parentTargetViewController()
        
        targetParentVC.addChildViewController(vc)
        vc.beginAppearanceTransition(true, animated: true)
        
        objc_setAssociatedObject(self, &semiModalViewController, vc, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &semiModalDismissBlock, ClosureWrapper(closure: dismissBlock), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    
        presentSemiView(vc.view, options: options) {
            vc.didMoveToParentViewController(targetParentVC)
            vc.endAppearanceTransition()
            
            completion?()
        }
    }
    
    public func presentSemiView(view: UIView) {
        presentSemiView(view, options: nil, completion: nil)
    }
        
    public func presentSemiView(view: UIView, options: [String: AnyObject]?) {
        presentSemiView(view, options: options, completion: nil)
    }
        
    public func presentSemiView(view: UIView, options: [String: AnyObject]?, completion: (() -> Void)?) {
        registerOptions(options)
        let target = parentTarget()
        
        if target.subviews.contains(view) {
            return
        }
        
        objc_setAssociatedObject(view, &semiModalPresentingViewController, self, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(interfaceOrientationDidChange(_:)),
                                                         name: UIDeviceOrientationDidChangeNotification,
                                                         object: nil)
        
        let semiViewHeight = view.frame.size.height
        var semiViewFrame: CGRect
        
        if UIDevice.isPad() {
            semiViewFrame = CGRect(x: (target.width - view.width / 2),
                                   y: (target.height - semiViewHeight),
                                   width: view.width,
                                   height: semiViewHeight)
        } else {
            semiViewFrame = CGRect(x: 0,
                                   y: target.height - semiViewHeight,
                                   width: target.width,
                                   height: semiViewHeight)
        }
        
        var overlay: UIView
        if let backgroundView = optionForKey(.BackgroundView) as? UIView {
            overlay = backgroundView
        } else {
            overlay = UIView()
        }
        
        overlay.frame = target.bounds
        overlay.backgroundColor = UIColor.blackColor()
        overlay.userInteractionEnabled = true
        overlay.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        overlay.tag = semiModalOverlayTag
        
        let screenshot = addOrUpdateParentScreenshotInView(overlay)
        target.addSubview(overlay)
        
        if optionForKey(.DisableCancel) as! Bool {
            let overlayFrame = CGRect(x: 0, y: 0, width: target.width, height: target.height - semiViewHeight)
            
            let dismissButton = UIButton(type: .Custom)
            dismissButton.addTarget(self, action: #selector(dismissSemiModalView), forControlEvents: .TouchUpInside)
            dismissButton.backgroundColor = UIColor.clearColor()
            dismissButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            dismissButton.frame = overlayFrame
            dismissButton.tag = semiModalDismissButtonTag
            
            overlay.addSubview(dismissButton)
        }
        
        if optionForKey(.PushParentBack) as! Bool {
            screenshot.layer.addAnimation(self.animationGroupForward(true), forKey: "pushedBackAnimation")
        }
        
        let duration = optionForKey(.AnimationDuration) as! NSTimeInterval
        UIView.animateWithDuration(duration) { 
            screenshot.alpha = self.optionForKey(.ParentAlpha) as! CGFloat
        }
        
        let transitionStyle = SemiModalTransitionStyle.init(rawValue: optionForKey(.TransitionStyle) as! String)
        if transitionStyle == SemiModalTransitionStyle.SlideUp {
           view.frame = CGRectOffset(semiViewFrame, 0, +semiViewHeight)
        } else {
            view.frame = semiViewFrame
        }
        
        if transitionStyle == SemiModalTransitionStyle.FadeIn || transitionStyle == SemiModalTransitionStyle.FadeOut {
            view.alpha = 0
        }
        
        if UIDevice.isPad() {
            view.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
        }
        
        view.tag = semiModalModalViewTag
        target.addSubview(view)
        
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = optionForKey(.ShadowOpacity)! as! Float
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        UIView.animateWithDuration(duration, animations: {
            if transitionStyle == SemiModalTransitionStyle.SlideUp {
                view.frame = semiViewFrame
            } else if transitionStyle == SemiModalTransitionStyle.FadeIn || transitionStyle == SemiModalTransitionStyle.FadeInOut {
                view.alpha = 1
            }
        }) { finished in
            if finished {
                NSNotificationCenter.defaultCenter().postNotificationName(semiModalDidShowNotification, object: self)
                completion?()
            }
        }
    }
    
    func parentTargetViewController() -> UIViewController {
        var target: UIViewController = self
        
        if optionForKey(.TraverseParentHierarchy) as! Bool {
            while target.parentViewController != nil {
                target = target.parentViewController!
            }
        }
        
        return target
    }
    
    func parentTarget() -> UIView {
        return parentTargetViewController().view
    }
    
    func addOrUpdateParentScreenshotInView(screenshotContainer: UIView) -> UIImageView {
        let target = parentTarget()
        let semiView = target.viewWithTag(semiModalModalViewTag)
        
        screenshotContainer.hidden = true
        semiView?.hidden = true
        
        UIGraphicsBeginImageContextWithOptions(target.bounds.size, true, UIScreen.mainScreen().scale)
        target.drawViewHierarchyInRect(target.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        screenshotContainer.hidden = false
        semiView?.hidden = false
        
        var screenshot = screenshotContainer.viewWithTag(semiModalScreenshotTag) as? UIImageView
        if screenshot == nil {
            screenshot = UIImageView(image: image)
            screenshot!.tag = semiModalScreenshotTag
            screenshot!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            screenshotContainer.addSubview(screenshot!)
        } else {
            screenshot!.image = image
        }
        
        return screenshot!
    }
    
    func interfaceOrientationDidChange(notification: NSNotification) {
        let overlay = parentTarget().viewWithTag(semiModalOverlayTag)
        addOrUpdateParentScreenshotInView(overlay!)
    }
    
    func dismissSemiModalView() {
        dismissSemiModalViewWithCompletion(nil)
    }
    
    func dismissSemiModalViewWithCompletion(completion: (() -> Void)?) {
        let target = parentTarget()
        let modal = target.viewWithTag(semiModalModalViewTag)!
        let overlay = target.viewWithTag(semiModalOverlayTag)!
        
        let transitionStyle = SemiModalTransitionStyle.init(rawValue: optionForKey(.TransitionStyle) as! String)
        let duration = optionForKey(.AnimationDuration) as! NSTimeInterval
        
        let vc = objc_getAssociatedObject(self, &semiModalViewController) as? UIViewController
        let dismissBlock = (objc_getAssociatedObject(self, &semiModalDismissBlock) as? ClosureWrapper)?.closure
        
        vc?.willMoveToParentViewController(nil)
        vc?.beginAppearanceTransition(false, animated: true)
        
        UIView.animateWithDuration(duration, animations: {
            if transitionStyle == SemiModalTransitionStyle.SlideUp {
                if UIDevice.isPad() {
                    modal.frame = CGRect(x: (target.width - modal.width) / 2, y: target.height,
                        width: modal.width, height: modal.height)
                } else {
                    modal.frame = CGRect(x: 0, y: target.height, width: modal.width, height: modal.height)
                }
            } else if transitionStyle == SemiModalTransitionStyle.FadeOut || transitionStyle == SemiModalTransitionStyle.FadeInOut {
                modal.alpha = 0.0
            }
        }) { finished in
            overlay.removeFromSuperview()
            modal.removeFromSuperview()
            
            vc?.removeFromParentViewController()
            vc?.endAppearanceTransition()
            
            dismissBlock?()
            
            objc_setAssociatedObject(self, &semiModalDismissBlock, nil, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            objc_setAssociatedObject(self, &semiModalViewController, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        }
        
        let screenshot = overlay.subviews.first as! UIImageView
        if optionForKey(.PushParentBack) as! Bool {
            screenshot.layer.addAnimation(animationGroupForward(false), forKey: "bringForwardAnimation")
        }
        
        UIView.animateWithDuration(duration, animations: { 
            screenshot.alpha = 1
            }) { finished in
                if finished {
                    NSNotificationCenter.defaultCenter().postNotificationName(semiModalDismissBlock, object: self)
                    completion?()
                }
        }
    }
    
    func animationGroupForward(forward: Bool) -> CAAnimationGroup {
        var id1 = CATransform3DIdentity
        id1.m34 = 1.0 / -900
        id1 = CATransform3DScale(id1, 0.95, 0.95, 1)
        
        if UIDevice.isPad() {
            id1 = CATransform3DRotate(id1, 7.5 * CGFloat(M_PI) / 180.0, 1, 0, 0)
        } else {
            id1 = CATransform3DRotate(id1, 15.0 * CGFloat(M_PI) / 180.0, 1, 0, 0)
        }
        
        var id2 = CATransform3DIdentity
        id2.m34 = id1.m34
        
        let scale = CGFloat(optionForKey(.ParentScale)! as! Float )
        if UIDevice.isPad() {
            id2 = CATransform3DTranslate(id2, 0, parentTarget().height * -0.04, 0)
            id2 = CATransform3DScale(id2, scale, scale, 1)
        } else {
            id2 = CATransform3DTranslate(id2, 0, parentTarget().height * -0.08, 0)
            id2 = CATransform3DScale(id2, scale, scale, 1)
        }
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = NSValue(CATransform3D: id1)
        
        let duration = optionForKey(.AnimationDuration)! as! Double
        animation.duration = duration / 2
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let animation2 = CABasicAnimation(keyPath: "transform")
        animation2.toValue = NSValue(CATransform3D: forward ? id2 : CATransform3DIdentity)
        animation2.beginTime = animation.duration
        animation2.duration = animation.duration
        animation2.fillMode = kCAFillModeForwards
        animation2.removedOnCompletion = false
        
        let group = CAAnimationGroup()
        group.fillMode = kCAFillModeForwards
        group.removedOnCompletion = false
        group.duration = animation.duration * 2
        group.animations = [animation, animation2]
        
        return group
    }

}
