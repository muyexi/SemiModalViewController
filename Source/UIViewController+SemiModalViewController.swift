import UIKit

extension Notification.Name {
    static let semiModalDidShow = Notification.Name("semiModalDidShow")
    static let semiModalDidHide = Notification.Name("semiModalDidHide")
    static let semiModalWasResized = Notification.Name("semiModalWasResized")
}

private var semiModalViewController: Void?
private var semiModalDismissBlock: Void?
private var semiModalPresentingViewController: Void?
private var targetViewControllerKey: Void?

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
        
        targetViewController.addChild(vc)
        vc.beginAppearanceTransition(true, animated: true)
        
        objc_setAssociatedObject(targetViewController, &semiModalViewController, vc, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(targetViewController, &semiModalDismissBlock, ClosureWrapper(closure: dismissBlock), .OBJC_ASSOCIATION_COPY_NONATOMIC)
    
        presentSemiView(vc.view, options: options) {
            vc.didMove(toParent: self.targetViewController)
            vc.endAppearanceTransition()
            
            completion?()
        }
    }
    
    public func presentSemiView(_ view: UIView, options: [SemiModalOption: Any]? = nil, completion: (() -> Void)? = nil) {
        registerOptions(options)

        if targetView.subviews.contains(view) {
            return
        }
        
        objc_setAssociatedObject(view, &semiModalPresentingViewController, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        NotificationCenter.default.addObserver(targetViewController,
                                               selector: #selector(interfaceOrientationDidChange(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
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
    
    var targetViewController: UIViewController {
        if let viewController = objc_getAssociatedObject(self, &targetViewControllerKey) as? UIViewController {
            return viewController
        } else {
            var viewController: UIViewController = self
            
            if optionForKey(.traverseParentHierarchy) as! Bool {
                while viewController.parent != nil {
                    viewController = viewController.parent!
                }
            }
            
            objc_setAssociatedObject(self, &targetViewControllerKey, viewController, .OBJC_ASSOCIATION_RETAIN)
            return viewController
        }
    }
    
    var targetView: UIView {
        return targetViewController.view
    }
    
    @discardableResult
    func addOrUpdateParentScreenshotInView(_ screenshotContainer: UIView) -> UIView {
        let semiView = targetView.viewWithTag(semiModalModalViewTag)
        
        screenshotContainer.isHidden = true
        semiView?.isHidden = true
        
        var snapshotView = screenshotContainer.viewWithTag(semiModalScreenshotTag) ?? UIView()
        snapshotView.removeFromSuperview()
        
        let image = targetView.asImage()
        snapshotView = UIImageView(image: image)
        snapshotView.tag = semiModalScreenshotTag
        
        screenshotContainer.addSubview(snapshotView)
        
        if optionForKey(.pushParentBack) as! Bool {
            let animationGroup = PushBackAnimationGroup(forward: true,
                                                        viewHeight: targetView.height,
                                                        options: self.options())
            snapshotView.layer.add(animationGroup, forKey: "pushedBackAnimation")
        }
        
        screenshotContainer.isHidden = false
        semiView?.isHidden = false
        
        return snapshotView
    }
    
    @objc func interfaceOrientationDidChange(_ notification: Notification) {
        guard let overlay = targetView.viewWithTag(semiModalOverlayTag) else { return }
        
        let view = addOrUpdateParentScreenshotInView(overlay)
        view.alpha = CGFloat(self.optionForKey(.parentAlpha) as! Double)
    }
    
    @objc public func dismissSemiModalView() {
        dismissSemiModalViewWithCompletion(nil)
    }
    
    public func dismissSemiModalViewWithCompletion(_ completion: (() -> Void)?) {
        guard let targetView = targetViewController.view,
            let modal = targetView.viewWithTag(semiModalModalViewTag),
            let overlay = targetView.viewWithTag(semiModalOverlayTag),
            let transitionStyle = optionForKey(.transitionStyle) as? SemiModalTransitionStyle,
            let duration = optionForKey(.animationDuration) as? TimeInterval else { return }
        
        let vc = objc_getAssociatedObject(targetViewController, &semiModalViewController) as? UIViewController
        let dismissBlock = (objc_getAssociatedObject(targetViewController, &semiModalDismissBlock) as? ClosureWrapper)?.closure
        
        vc?.willMove(toParent: nil)
        vc?.beginAppearanceTransition(false, animated: true)
        
        UIView.animate(withDuration: duration, animations: {
            if transitionStyle == .slideUp {
                let originX = UIDevice.isPad() ? (targetView.width - modal.width) / 2 : 0
                modal.frame = CGRect(x: originX, y: targetView.height, width: modal.width, height: modal.height)
            } else if transitionStyle == .fadeOut || transitionStyle == .fadeInOut {
                modal.alpha = 0.0
            }
        }, completion: { finished in
            overlay.removeFromSuperview()
            modal.removeFromSuperview()
            
            vc?.removeFromParent()
            vc?.endAppearanceTransition()
            
            dismissBlock?()
            
            objc_setAssociatedObject(self.targetViewController, &semiModalDismissBlock, nil, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            objc_setAssociatedObject(self.targetViewController, &semiModalViewController, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            NotificationCenter.default.removeObserver(self.targetViewController, name: UIDevice.orientationDidChangeNotification, object: nil)
        }) 
        
        if let screenshot = overlay.subviews.first {
            if let pushParentBack = optionForKey(.pushParentBack) as? Bool , pushParentBack {
                let animationGroup = PushBackAnimationGroup(forward: false,
                                                            viewHeight: targetView.height,
                                                            options: self.options())
                screenshot.layer.add(animationGroup, forKey: "bringForwardAnimation")
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

    }
    
    func overlayView() -> UIView {
        var view: UIView
        if let backgroundView = optionForKey(.backgroundView) as? UIView {
            view = backgroundView
        } else {
            view = UIView()
        }
        
        view.frame = targetView.bounds
        view.backgroundColor = UIColor.black
        view.isUserInteractionEnabled = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.tag = semiModalOverlayTag
        
        if optionForKey(.disableCancel) as! Bool {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSemiModalView))
            view.addGestureRecognizer(tapGesture)
        }
        
        return view
    }
}
