import UIKit

extension Notification.Name {
    static let semiModalDidShow = Notification.Name("semiModalDidShow")
    static let semiModalDidHide = Notification.Name("semiModalDidHide")
    static let semiModalWasResized = Notification.Name("semiModalWasResized")
}

private var semiModalViewController: Void?
private var semiModalDismissBlock: Void?
private var semiModalPresentingViewController: Void?

private let semiModalOverlayTag = 10001
private let semiModalScreenshotTag = 10002
private let semiModalModalViewTag = 10003

public enum SemiModalOption: String {
    case traverseParentHierarchy
    case pushParentBack
    case animationDuration
    case parentAlpha
    case parentScale
    case shadowOpacity
    case transitionStyle
    case disableCancel
    case backgroundView
}

public enum SemiModalTransitionStyle: String {
   case slideUp
   case fadeInOut
   case fadeIn
   case fadeOut
}

extension UIViewController {
 
    public func presentSemiViewController(_ vc: UIViewController,
                                   options: [SemiModalOption: Any]? = nil,
                                   completion: (() -> Void)? = nil,
                                   dismissBlock: (() -> Void)? = nil) {
        registerOptions(options)
        let targetParentVC = parentTargetViewController()
        
        targetParentVC.addChildViewController(vc)
        vc.beginAppearanceTransition(true, animated: true)
        
        objc_setAssociatedObject(self, &semiModalViewController, vc, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &semiModalDismissBlock, ClosureWrapper(closure: dismissBlock), .OBJC_ASSOCIATION_COPY_NONATOMIC)
    
        presentSemiView(vc.view, options: options) {
            vc.didMove(toParentViewController: targetParentVC)
            vc.endAppearanceTransition()
            
            completion?()
        }
    }
    
    public func presentSemiView(_ view: UIView, options: [SemiModalOption: Any]? = nil, completion: (() -> Void)? = nil) {
        registerOptions(options)
        let targetView = parentTargetView()
        
        if targetView.subviews.contains(view) {
            return
        }
        
        objc_setAssociatedObject(view, &semiModalPresentingViewController, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(interfaceOrientationDidChange(_:)),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil)
        
        let semiViewHeight = view.frame.size.height
        let semiViewFrame = CGRect(x: 0, y: targetView.height - semiViewHeight, width: targetView.width, height: semiViewHeight)
        
        let overlay = overlayView()
        targetView.addSubview(overlay)
        
        let screenshot = addOrUpdateParentScreenshotInView(overlay)
        
        let duration = optionForKey(.animationDuration) as! TimeInterval
        UIView.animate(withDuration: duration, animations: { 
            screenshot.alpha = CGFloat(self.optionForKey(.parentAlpha) as! Double)
        }) 
        
        let transitionStyle = optionForKey(.transitionStyle) as! SemiModalTransitionStyle
        if transitionStyle == .slideUp {
           view.frame = semiViewFrame.offsetBy(dx: 0, dy: +semiViewHeight)
        } else {
            view.frame = semiViewFrame
        }
        
        if transitionStyle == .fadeIn || transitionStyle == .fadeOut {
            view.alpha = 0
        }
        
        if UIDevice.isPad() {
            view.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        } else {
            view.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        }
        
        view.tag = semiModalModalViewTag
        targetView.addSubview(view)
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = Float(optionForKey(.shadowOpacity) as! Double)
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        UIView.animate(withDuration: duration, animations: {
            if transitionStyle == .slideUp {
                view.frame = semiViewFrame
            } else if transitionStyle == .fadeIn || transitionStyle == .fadeInOut {
                view.alpha = 1
            }
        }, completion: { finished in
            if finished {
                NotificationCenter.default.post(name: .semiModalDidShow, object: self)
                completion?()
            }
        }) 
    }
    
    func parentTargetViewController() -> UIViewController {
        var viewController: UIViewController = self
        
        if optionForKey(.traverseParentHierarchy) as! Bool {
            while viewController.parent != nil {
                viewController = viewController.parent!
            }
        }
        
        return viewController
    }
    
    func parentTargetView() -> UIView {
        return parentTargetViewController().view
    }
    
    @discardableResult
    func addOrUpdateParentScreenshotInView(_ screenshotContainer: UIView) -> UIView {
        let targetView = parentTargetView()
        let semiView = targetView.viewWithTag(semiModalModalViewTag)
        
        screenshotContainer.isHidden = true
        semiView?.isHidden = true
        
        var snapshotView = screenshotContainer.viewWithTag(semiModalScreenshotTag)
        snapshotView?.removeFromSuperview()
        
        snapshotView = targetView.snapshotView(afterScreenUpdates: true)
        snapshotView?.tag = semiModalScreenshotTag
        
        screenshotContainer.addSubview(snapshotView!)
        
        if optionForKey(.pushParentBack) as! Bool {
            snapshotView?.layer.add(self.animationGroupForward(true), forKey: "pushedBackAnimation")
        }
        
        screenshotContainer.isHidden = false
        semiView?.isHidden = false
        
        return snapshotView!
    }
    
    func interfaceOrientationDidChange(_ notification: Notification) {
        let overlay = parentTargetView().viewWithTag(semiModalOverlayTag)
        addOrUpdateParentScreenshotInView(overlay!)
    }
    
    func dismissSemiModalView() {
        dismissSemiModalViewWithCompletion(nil)
    }
    
    func dismissSemiModalViewWithCompletion(_ completion: (() -> Void)?) {
        let targetView = parentTargetView()
        let modal = targetView.viewWithTag(semiModalModalViewTag)!
        let overlay = targetView.viewWithTag(semiModalOverlayTag)!
        
        let transitionStyle = optionForKey(.transitionStyle) as! SemiModalTransitionStyle
        let duration = optionForKey(.animationDuration) as! TimeInterval
        
        let vc = objc_getAssociatedObject(self, &semiModalViewController) as? UIViewController
        let dismissBlock = (objc_getAssociatedObject(self, &semiModalDismissBlock) as? ClosureWrapper)?.closure
        
        vc?.willMove(toParentViewController: nil)
        vc?.beginAppearanceTransition(false, animated: true)
        
        UIView.animate(withDuration: duration, animations: {
            if transitionStyle == .slideUp {
                if UIDevice.isPad() {
                    modal.frame = CGRect(x: (targetView.width - modal.width) / 2, y: targetView.height,
                        width: modal.width, height: modal.height)
                } else {
                    modal.frame = CGRect(x: 0, y: targetView.height, width: modal.width, height: modal.height)
                }
            } else if transitionStyle == .fadeOut || transitionStyle == .fadeInOut {
                modal.alpha = 0.0
            }
        }, completion: { finished in
            overlay.removeFromSuperview()
            modal.removeFromSuperview()
            
            vc?.removeFromParentViewController()
            vc?.endAppearanceTransition()
            
            dismissBlock?()
            
            objc_setAssociatedObject(self, &semiModalDismissBlock, nil, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            objc_setAssociatedObject(self, &semiModalViewController, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
        }) 
        
        let screenshot = overlay.subviews.first!
        if optionForKey(.pushParentBack) as! Bool {
            screenshot.layer.add(animationGroupForward(false), forKey: "bringForwardAnimation")
        }
        
        UIView.animate(withDuration: duration, animations: { 
            screenshot.alpha = 1
            }, completion: { finished in
                if finished {
                    NotificationCenter.default.post(name: .semiModalDidHide, object: self)
                    completion?()
                }
        }) 
    }
    
    func animationGroupForward(_ forward: Bool) -> CAAnimationGroup {
        var id1 = CATransform3DIdentity
        id1.m34 = 1.0 / -900
        id1 = CATransform3DScale(id1, 0.95, 0.95, 1)
        
        if UIDevice.isPad() {
            id1 = CATransform3DRotate(id1, 7.5 * CGFloat(Double.pi) / 180.0, 1, 0, 0)
        } else {
            id1 = CATransform3DRotate(id1, 15.0 * CGFloat(Double.pi) / 180.0, 1, 0, 0)
        }
        
        var id2 = CATransform3DIdentity
        id2.m34 = id1.m34
        
        let scale = CGFloat(optionForKey(.parentScale) as! Double)
        if UIDevice.isPad() {
            id2 = CATransform3DTranslate(id2, 0, parentTargetView().height * -0.04, 0)
            id2 = CATransform3DScale(id2, scale, scale, 1)
        } else {
            id2 = CATransform3DTranslate(id2, 0, parentTargetView().height * -0.08, 0)
            id2 = CATransform3DScale(id2, scale, scale, 1)
        }
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = NSValue(caTransform3D: id1)
        
        let duration = optionForKey(.animationDuration) as! Double
        animation.duration = duration / 2
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let animation2 = CABasicAnimation(keyPath: "transform")
        animation2.toValue = NSValue(caTransform3D: forward ? id2 : CATransform3DIdentity)
        animation2.beginTime = animation.duration
        animation2.duration = animation.duration
        animation2.fillMode = kCAFillModeForwards
        animation2.isRemovedOnCompletion = false
        
        let group = CAAnimationGroup()
        group.fillMode = kCAFillModeForwards
        group.isRemovedOnCompletion = false
        group.duration = animation.duration * 2
        group.animations = [animation, animation2]
        
        return group
    }

    func overlayView() -> UIView {
        var overlay: UIView
        if let backgroundView = optionForKey(.backgroundView) as? UIView {
            overlay = backgroundView
        } else {
            overlay = UIView()
        }
        
        overlay.frame = parentTargetView().bounds
        overlay.backgroundColor = UIColor.black
        overlay.isUserInteractionEnabled = true
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.tag = semiModalOverlayTag
        
        if optionForKey(.disableCancel) as! Bool {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSemiModalView))
            overlay.addGestureRecognizer(tapGesture)
        }
        return overlay
    }
}
