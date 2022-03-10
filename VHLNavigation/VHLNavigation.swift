//
//  VHLNavigation.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/9/29.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

// MARK: 导航栏切换样式
enum VHLNavigationSwitchStyle {
    case transition     // 颜色过渡
    case fakeNavBar     // 两种不同颜色导航栏，类似微信红包
}
// MARK: VHLNavigation
class VHLNavigation: NSObject {
    static let def = VHLNavigation()
    
    var navBackgroundColor: UIColor = .white        // 默认导航栏背景颜色
    var navBackgroundAlpha: CGFloat = 1.0
    var navBarTintColor: UIColor = .black           // 默认导航栏按钮颜色
    var navBarTitleColor: UIColor = .black          // 默认导航栏标题颜色
    var navBarShadowImageHidden: Bool = false       // 默认导航栏分割线是否隐藏
    
    var ignoreVCList: Set<String> = []              // 忽略的 viewControllers 列表
    
    override init() {

    }
    
    static func hook() {
        UINavigationBar.vhl_hookMethods()
        UIViewController.vhl_hookMethods()
        UINavigationController.vhl_navHookMethods()
    }
}
extension VHLNavigation {
    func isIgnoreVC(_ vcName: String) -> Bool {
        // 忽略系统类
        let systemClassPrefixs = ["_UI", "UI", "SFSafari", "MFMail", "PUPhoto", "CKSMS", "MPMedia"]
        for prefix in systemClassPrefixs {
            if vcName.hasPrefix(prefix) {
                return true
            }
        }
        
        return self.ignoreVCList.contains(vcName)
    }
    func addIgnoreVCName(_ vcName: String) {
        self.ignoreVCList.insert(vcName)
    }
    func removeIgnoreVCName(_ vcName: String) {
        self.ignoreVCList.remove(vcName)
    }
    func removeAllIgnoreVCName() {
        self.ignoreVCList.removeAll()
    }
}
extension VHLNavigation {
    // MARK: 是否是 iPhone X 系列的异形屏
    static func isIPhoneXSeries() -> Bool {
        // 不是 iPhone
        if UIDevice.current.userInterfaceIdiom != .phone {
            return false
        }
        if #available(iOS 11.0, *) {
            if let mainWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                if mainWindow.safeAreaInsets.top > 0 {
                    return true
                }
            }
        }
        
        return false
    }
    // MARK: fromColor toColor 过渡的颜色
    static func middleColor(from fromColor: UIColor, to toColor: UIColor, percent: CGFloat) -> UIColor {
        // get current color RGBA
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        // get to color RGBA
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        // calculate middle color RGBA
        let newRed = fromRed + (toRed - fromRed) * percent
        let newGreen = fromGreen + (toGreen - fromGreen) * percent
        let newBlue = fromBlue + (toBlue - fromBlue) * percent
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
    // MARK: middle alpha
    static func middleAlpha(from fromAlpha: CGFloat, to toAlpha: CGFloat, percent: CGFloat) -> CGFloat {
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        return newAlpha
    }
}
// MARK: - UINavigationBar 相关修改
extension UINavigationBar {
    // MARK: property
    fileprivate struct AssociatedKeys {
        static var backgroundView: UIView = UIView()
        static var backgroundImageView: UIImageView = UIImageView()
    }
    
    fileprivate var backgroundView: UIView? {
        get {
            guard let bgView = objc_getAssociatedObject(self, &AssociatedKeys.backgroundView) as? UIView else {
                return nil
            }
            return bgView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var backgroundImageView: UIImageView? {
        get {
            guard let bgImageView = objc_getAssociatedObject(self, &AssociatedKeys.backgroundImageView) as? UIImageView else {
                return nil
            }
            return bgImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundImageView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    // MARK: 设置导航栏自定义背景View
    public func vhl_setBackgroundView(_ view: UIView) {
        backgroundImageView?.removeFromSuperview()
        backgroundImageView = nil
        
        backgroundView?.removeFromSuperview()
        
        /// 这里需要将系统添加的模糊层隐藏，不然会在自己添加的背景层再添加一层模糊层
        if self.subviews.first?.subviews.count ?? 0 > 1 {
            if let backgroundEffectView = self.subviews.first?.subviews[1] {
                backgroundEffectView.alpha = 0.0
            }
        }
        
        if let viewCopyData = try? NSKeyedArchiver.archivedData(withRootObject: view, requiringSecureCoding: false) {
//            if let viewCopy = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIView.self, from: viewCopyData) {
            if let viewCopy = NSKeyedUnarchiver.unarchiveObject(with: viewCopyData) as? UIView {
                self.backgroundView = viewCopy
                if let backgroundView = self.backgroundView {
                    backgroundView.frame = self.subviews.first!.bounds
                    backgroundView.autoresizingMask = [.flexibleWidth,
                                                       .flexibleHeight,
                                                       .flexibleBottomMargin]
                    /// iOS 11 下导航栏不显示问题
                    if self.subviews.count > 0 {
                        self.subviews.first?.insertSubview(backgroundView, at: 0)
                    } else {
                        self.insertSubview(backgroundView, at: 0)
                    }
                }
            }
        }
    }
    // MARK: 设置导航栏背景图片
    public func vhl_setBackgroundImage(_ image: UIImage) {
        backgroundView?.removeFromSuperview()
        backgroundView = nil
        
        if backgroundImageView == nil {
            // add a image(nil color) to _UIBarBackground make it clear
            setBackgroundImage(UIImage(), for: .default)
            if let superView = self.subviews.first {
                self.backgroundImageView = UIImageView(frame: superView.bounds)
                if let backgroundImageView = self.backgroundImageView {
                    backgroundImageView.tag = 10102
                    backgroundImageView.autoresizingMask = [.flexibleWidth,
                                                            .flexibleHeight,
                                                            .flexibleBottomMargin]
                    superView.insertSubview(backgroundImageView, at: 0)
                }
            }
        }
        self.backgroundImageView?.image = image
    }
    // MARK: 设置导航栏背景颜色
    public func vhl_setBackgroundColor(_ color: UIColor) {
        backgroundImageView?.removeFromSuperview()
        backgroundImageView = nil
        
        /// 这里自定义 bgView 也是使用的同一个变量
        let bgViewTag = 10101
        if backgroundView?.tag ?? 0 != bgViewTag {
            backgroundView?.removeFromSuperview()
            backgroundView = nil
        }
        
        if backgroundView == nil {
            if let superView = self.subviews.first {
                // add a image(nil color) to _UIBarBackground make it clear
                setBackgroundImage(UIImage(), for: .default)
                self.backgroundView = UIView(frame: superView.bounds)
                self.backgroundView?.tag = bgViewTag
                if let backgroundView = self.backgroundView {
                    backgroundView.autoresizingMask = [.flexibleWidth,
                                                       .flexibleHeight,
                                                       .flexibleBottomMargin]
                    superView.insertSubview(backgroundView, at: 0)
                }
            }
        }
        self.backgroundView?.backgroundColor = color
    }
    // MARK: 设置导航栏背景透明度
    public func vhl_setBackgroundAlpha(_ alpha: CGFloat) {
        // set _UIBarBackground alpha
        if let barBackgroundView = self.subviews.first {
            if #available(iOS 11.0, *) {   // sometimes we can't change _UIBarBackground alpha
                for view in barBackgroundView.subviews {
                    view.alpha = alpha
                }
            }
            barBackgroundView.alpha = alpha
        }
    }
    // MARK: 设置导航栏所有 barButtonItem 的透明度
    public func vhl_setBarButtonItemsAlpha(alpha: CGFloat, hasSystemBackIndicator:Bool) {
        for view in self.subviews {
            if hasSystemBackIndicator {
                if let _UIBarBackgroundClass = NSClassFromString("_UIBarBackground") {
                    if !view.isKind(of: _UIBarBackgroundClass) {
                        view.alpha = alpha
                    }
                }
                if let _UINavigationBarBackground = NSClassFromString("_UINavigationBarBackground") {
                    if !view.isKind(of: _UINavigationBarBackground) {
                        view.alpha = alpha
                    }
                }
            } else {
                // 这里如果不做判断的话，会显示 backIndicatorImage(系统返回按钮)
                if let _UINavigationBarBackIndicatorViewClass = NSClassFromString("_UINavigationBarBackIndicatorView"),
                    !view.isKind(of: _UINavigationBarBackIndicatorViewClass) {
                    if let _UIBarBackgroundClass = NSClassFromString("_UIBarBackground") {
                        if view.isKind(of: _UIBarBackgroundClass) {
                            view.alpha = alpha
                        }
                    }
                    
                    if let _UINavigationBarBackground = NSClassFromString("_UINavigationBarBackground") {
                        if !view.isKind(of: _UINavigationBarBackground) {
                            view.alpha = alpha
                        }
                    }
                }
            }
        }
    }
    // MARK: 设置默认的返回箭头是否隐藏
    public func vhl_setBarBackIndicatorViewIsHidden(_ isHidden: Bool) {
        for view in self.subviews {
            if let _UINavigationBarBackIndicatorViewClass = NSClassFromString("_UINavigationBarBackIndicatorView") {
                if view.isKind(of: _UINavigationBarBackIndicatorViewClass) {
                    view.isHidden = isHidden
                }
            }
        }
    }
    // MARK: 分割线是否隐藏
    public func vhl_setShadowImageIsHidden(_ isHidden: Bool) {
        self.shadowImage = isHidden ? UIImage() : nil
        // iOS 11 后设置 shadowImage 无效
        self.setValue(isHidden, forKey: "hidesShadow")
        self.layoutIfNeeded()
    }
    // MARK: 设置/获取导航栏偏移量
    public func vhl_setTranslationY(y: CGFloat) {
        self.transform = CGAffineTransform(translationX: 0, y: y)
    }
    public func vhl_translationY() -> CGFloat {
        return self.transform.ty
    }
    
    // MARK: Hook methods
    private static let onceToken = UUID().uuidString
    static fileprivate func vhl_hookMethods() {
        DispatchQueue.vhl_once(token: onceToken) {
            let needSwizzleSelectorArr = [
                #selector(setter: titleTextAttributes)
            ]
            
            for selector in needSwizzleSelectorArr {
                let str = ("vhl_" + selector.description)
                if let originalMethod = class_getInstanceMethod(self, selector),
                   let swizzledMethod = class_getInstanceMethod(self, Selector(str)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
    @objc func vhl_setTitleTextAttributes(_ newTitleTextAttributes:[NSAttributedString.Key : Any]?) {
        guard var attributes = newTitleTextAttributes else { return }
        
        guard let originTitleTextAttributes = titleTextAttributes else {
            vhl_setTitleTextAttributes(attributes)
            return
        }
        
        var titleColor:UIColor?
        for attribute in originTitleTextAttributes {
            if attribute.key == NSAttributedString.Key.foregroundColor {
                titleColor = attribute.value as? UIColor
                break
            }
        }
        
        guard let originTitleColor = titleColor else {
            vhl_setTitleTextAttributes(attributes)
            return
        }

        if attributes[NSAttributedString.Key.foregroundColor] == nil {
            attributes.updateValue(originTitleColor, forKey: NSAttributedString.Key.foregroundColor)
        }
        
        // crash: 'Have you sent -vhl_setTitleTextAttributes:
        /// ** VHLNavigation.hook()  需要将在 viewController 初始化的最前面调用 **
        vhl_setTitleTextAttributes(attributes)
    }
}
// MARK: - Hook UINavigationController
extension UINavigationController: UINavigationBarDelegate {
    // MARK: 状态栏相关
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? UIStatusBarStyle.default
    }
    // MARK: 更新导航栏相关样式
    fileprivate func setNeedsNavigationBarUpdate(backgroundView: UIView) {           // 导航栏背景视图
        navigationBar.vhl_setBackgroundView(backgroundView)
    }
    fileprivate func setNeedsNavigationBarUpdate(backgroundImage: UIImage) {        // 导航栏背景图片
        navigationBar.vhl_setBackgroundImage(backgroundImage)
    }
    fileprivate func setNeedsNavigationBarUpdate(backgroundColor: UIColor) {        // 导航栏背景颜色
        navigationBar.vhl_setBackgroundColor(backgroundColor)
    }
    fileprivate func setNeedsNavigationBarUpdate(backgroundAlpha: CGFloat) {        // 导航栏背景透明度
        navigationBar.vhl_setBackgroundAlpha(backgroundAlpha)
    }
    fileprivate func setNeedsNavigationBarUpdate(tintColor: UIColor) {              // 导航栏按钮颜色
        navigationBar.tintColor = tintColor
    }
    fileprivate func setNeedsNavigationBarUpdate(titleColor: UIColor) {             // 导航栏标题颜色
        guard let titleTextAttributes = navigationBar.titleTextAttributes else {
            navigationBar.titleTextAttributes = [.foregroundColor: titleColor]
            return
        }
        var newTitleTextAttributes = titleTextAttributes
        newTitleTextAttributes.updateValue(titleColor, forKey: .foregroundColor)
        navigationBar.titleTextAttributes = newTitleTextAttributes
    }
    fileprivate func setNeedsNavigationBarUpdate(hidenShadowImage: Bool) {         // 导航栏分割线隐藏
        navigationBar.vhl_setShadowImageIsHidden(hidenShadowImage)
    }
    
    // MARK: - Hook methods
    private static let onceToken = UUID().uuidString
    static fileprivate func vhl_navHookMethods() {      // NavigationController 是继承自 vc 的
        DispatchQueue.vhl_once(token: onceToken) {
            let needSwizzleSelectorArr = [
                NSSelectorFromString("_updateInteractiveTransition:"),
                #selector(popToViewController(_:animated:)),
                #selector(popToRootViewController(animated:)),
                #selector(pushViewController(_:animated:)),
            ]

            for selector in needSwizzleSelectorArr {
                // _updateInteractiveTransition:  =>  vhl_updateInteractiveTransition:
                let str = ("vhl_" + selector.description).replacingOccurrences(of: "__", with: "_")
                if let originalMethod = class_getInstanceMethod(self, selector),
                    let swizzledMethod = class_getInstanceMethod(self, Selector(str)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
    // MARK: hook popVC
    fileprivate struct VHLPOPProperties {
        static var popDuration = 0.13       // 侧滑动画时间
        static var displayCount = 0         //
        static var popProgress: CGFloat {   // pop 进度
            let all:CGFloat = CGFloat(60.0 * popDuration)
            let current = min(all, CGFloat(displayCount))
            return current / all
        }
    }
    @objc func vhl_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let displayLink = CADisplayLink(target: self, selector: #selector(popNeedDisplay))
        displayLink.add(to: RunLoop.main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink.invalidate()
            VHLPOPProperties.displayCount = 0
        }
        CATransaction.setAnimationDuration(VHLPOPProperties.popDuration)
        CATransaction.begin()
        let vcs = vhl_popToViewController(viewController, animated: animated) // 调用自己
        CATransaction.commit()
        return vcs
    }
    @objc func vhl_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        var displayLink: CADisplayLink? = CADisplayLink(target: self, selector: #selector(popNeedDisplay))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            VHLPOPProperties.displayCount = 0
        }
        CATransaction.setAnimationDuration(VHLPOPProperties.popDuration)
        CATransaction.begin()
        let vcs = vhl_popToRootViewControllerAnimated(animated) // 调用自己
        CATransaction.commit()
        return vcs
    }
    // MARK: DisplayLink 侧滑监听
    @objc fileprivate func popNeedDisplay() {
        guard let topViewController = self.topViewController, let coordinator = topViewController.transitionCoordinator else { return }
        
        VHLPOPProperties.displayCount += 1
        let popProgress = VHLPOPProperties.popProgress
        let fromVC = coordinator.viewController(forKey: .from)
        let toVC = coordinator.viewController(forKey: .to)
        updateNavigationBar(fromVC: fromVC, toVC: toVC, progress: popProgress)
    }
    // MARK: hook push vc
    fileprivate struct VHLPushProperties {
        static var pushDuration = 0.13       // 侧滑动画时间
        static var displayCount = 0         //
        static var pushProgress: CGFloat {    // pop 进度
            let all:CGFloat = CGFloat(60.0 * pushDuration)
            let current = min(all, CGFloat(displayCount))
            return current / all
        }
    }
    @objc func vhl_pushViewController(_ viewController: UIViewController, animated: Bool) {
        var displayLink: CADisplayLink? = CADisplayLink(target: self, selector: #selector(pushNeedDisplay))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            VHLPushProperties.displayCount = 0
            viewController.pushToCurrentVCFinished = true
        }
        CATransaction.setAnimationDuration(VHLPushProperties.pushDuration)
        CATransaction.begin()
        vhl_pushViewController(viewController, animated: animated) // 调用自己
        CATransaction.commit()
    }
    @objc fileprivate func pushNeedDisplay() {
        guard let topViewController = self.topViewController, let coordinator = topViewController.transitionCoordinator else { return }
        if topViewController.isMotalFrom() { return }
        
        VHLPushProperties.displayCount += 1
        let pushProgress = VHLPushProperties.pushProgress
        let fromVC = coordinator.viewController(forKey: .from)
        let toVC = coordinator.viewController(forKey: .to)
        updateNavigationBar(fromVC: fromVC, toVC: toVC, progress: pushProgress)
    }
    // MARK: hook 导航栏侧滑进度
    @objc func vhl_updateInteractiveTransition(_ percentComplete: CGFloat) {
        guard let topViewController = self.topViewController, let coordinator = topViewController.transitionCoordinator else {
            vhl_updateInteractiveTransition(percentComplete)
            return
        }
        let fromVC = coordinator.viewController(forKey: .from)
        let toVC = coordinator.viewController(forKey: .to)
        updateNavigationBar(fromVC: fromVC, toVC: toVC, progress: percentComplete)
        // 调用自己
        vhl_updateInteractiveTransition(percentComplete)
    }
    
    // MARK: 根据进度更新导航栏
    fileprivate func updateNavigationBar(fromVC: UIViewController?, toVC: UIViewController?, progress: CGFloat) {
        // 背景颜色变化
        if let fromVC = fromVC, let toVC = toVC {
            // 是否是被忽略的 VC
            if fromVC.isIgnoreVC() || toVC.isIgnoreVC() { return }
            // 是否需要添加假的导航栏
            if self.topViewController?.shouldAddFakeNavigationBar() ?? false { return }
            
            // 颜色过渡
            // 1. 导航栏按钮颜色
            let fromTintColor = fromVC.vhl_navBarTintColor
            let toTintColor = toVC.vhl_navBarTintColor
            let newTintColor = VHLNavigation.middleColor(from: fromTintColor, to: toTintColor, percent: progress)
            self.setNeedsNavigationBarUpdate(tintColor: newTintColor)
            
            // 2. 导航栏标题颜色
            let fromTitleColor = fromVC.vhl_navBarTitleColor
            let toTitleColor = toVC.vhl_navBarTitleColor
            let newTitleColor = VHLNavigation.middleColor(from: fromTitleColor, to: toTitleColor, percent: progress)
            self.setNeedsNavigationBarUpdate(titleColor: newTitleColor)
            
            /// 背景颜色过渡时，判断是否有相同的自定义背景 View
            if fromVC.vhl_navBarBackgroundView != nil &&
                self.topViewController?.fromToVCBackgroundViewIsSame() ?? false { return }
            
            // 3. 导航栏背景颜色
            let fromBackgroundColor = fromVC.vhl_navBarBackgroundColor
            let toBackgroundColor = toVC.vhl_navBarBackgroundColor
            let newBackgroundColor = VHLNavigation.middleColor(from: fromBackgroundColor, to: toBackgroundColor, percent: progress)
            self.setNeedsNavigationBarUpdate(backgroundColor: newBackgroundColor)
            
            // 4. 导航栏透明度
            let fromAlpha = fromVC.vhl_navBarBackgroundAlpha
            let toAlpha = toVC.vhl_navBarBackgroundAlpha
            let newAlpha = VHLNavigation.middleAlpha(from: fromAlpha, to: toAlpha, percent: progress)
            self.setNeedsNavigationBarUpdate(backgroundAlpha: newAlpha)
        }
    }
    // MARK: Delegate - UINavigationBarDelegate
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let topVC = self.topViewController, let coor = topVC.transitionCoordinator, coor.initiallyInteractive {
            if #available(iOS 10.0, *) {
                coor.notifyWhenInteractionChanges { (context) in
                    self.dealInteractionChanges(context)
                }
            } else {
                coor.notifyWhenInteractionEnds { (context) in
                    self.dealInteractionChanges(context)
                }
            }
        }
        let itemCount = navigationBar.items?.count ?? 0
        let n = self.viewControllers.count >= itemCount ? 2 : 1
        let popToVC = self.viewControllers[viewControllers.count - n]
        popToViewController(popToVC, animated: true)
        // fix: iOS 13 下点击导航栏返回按钮闪退
        if #available(iOS 13.0, *) {
            return false
        }
        return true
    }
    // deal the gesture of return break off
    private func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
        let animations: (UITransitionContextViewControllerKey) -> () = {
            if !(self.topViewController?.shouldAddFakeNavigationBar() ?? false) {
                let curBackgroundColor = context.viewController(forKey: $0)?.vhl_navBarBackgroundColor ?? VHLNavigation.def.navBackgroundColor
                let curBackgroundAlpha = context.viewController(forKey: $0)?.vhl_navBarBackgroundAlpha ?? VHLNavigation.def.navBackgroundAlpha
                
                self.setNeedsNavigationBarUpdate(backgroundColor: curBackgroundColor)
                self.setNeedsNavigationBarUpdate(backgroundAlpha: curBackgroundAlpha)
            }
        }
        if context.isCancelled {
            let cancelDuration = context.transitionDuration * Double(context.percentComplete)
            UIView.animate(withDuration: cancelDuration) {
                animations(.from)
            }
        } else {
            let finishDuration = context.transitionDuration * Double(1 - context.percentComplete)
            UIView.animate(withDuration: finishDuration) {
                animations(.to)
            }
        }
    }
}
extension UINavigationController {
    // 1. 是否支持自动转屏
    open override var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? false
    }
    // 2. 支持哪些屏幕方向
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? .portrait
    }
    // 4. 默认的屏幕方向（当前 ViewController 必须是通过模态出来的 UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
}
// MARK: - Hook ViewController
extension UIViewController {
    fileprivate struct AssociatedKeys {
        // 跳转到当前是否已完成
        static var pushToCurrentVCFinished: Bool = false
        // 跳转到下一个 VC 是否已完成
        static var pushToNextVCFinished: Bool = false
        
        // 当前导航栏切换样式
        static var navSwitchStyle: VHLNavigationSwitchStyle = .transition
        // 当前导航栏是否隐藏
        static var navBarHide: Bool = false
        // 当前导航栏背景视图
        static var navBarBackgroundView: UIView?
        // 当前导航栏背景图片
        static var navBarBackgroundImage: UIImage?
        // 当前导航栏背景颜色
        static var navBarBackgroundColor: UIColor = VHLNavigation.def.navBackgroundColor
        // 当前导航栏透明度
        static var navBarBackgroundAlpha: CGFloat = 1.0
        // 当前导航栏按钮颜色
        static var navBarTintColor: UIColor = VHLNavigation.def.navBarTintColor
        // 当前导航栏标题颜色
        static var navBarTitleColor: UIColor = VHLNavigation.def.navBarTitleColor
        // 当前导航栏底部分割线是否隐藏
        static var navBarShadowImageHide: Bool = VHLNavigation.def.navBarShadowImageHidden
        // 当前导航栏浮动高度
        static var navBarTranslationY: CGFloat = 0.0
        // 当前状态栏样式
        static var statusBarStyle: UIStatusBarStyle = .default
        // 当前侧滑手势是否可用
        static var interactivePopEnable: Bool = true
        
        // 假的导航栏
        static var fakeNavBar: UIImageView = UIImageView()
        static var tempBackView: UIView?
    }
    // MARK: property
    fileprivate var pushToCurrentVCFinished: Bool {
        get {
            guard let isFinished = objc_getAssociatedObject(self, &AssociatedKeys.pushToCurrentVCFinished) as? Bool else {
                return false
            }
            return isFinished
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pushToCurrentVCFinished, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    fileprivate var pushToNextVCFinished: Bool {
        get {
            guard let isFinished = objc_getAssociatedObject(self, &AssociatedKeys.pushToNextVCFinished) as? Bool else {
                return false
            }
            return isFinished
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pushToNextVCFinished, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    fileprivate var fakeNavBar: UIImageView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.fakeNavBar) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.fakeNavBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    fileprivate var tempBackView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.tempBackView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.tempBackView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    // MARK: 公开属性 ****
    /// 当前导航栏切换样式
    var vhl_navSwitchStyle: VHLNavigationSwitchStyle {
        get {
            guard let style = objc_getAssociatedObject(self, &AssociatedKeys.navSwitchStyle) as? VHLNavigationSwitchStyle else {
                return .transition
            }
            return style
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navSwitchStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 当前导航栏是否隐藏
    var vhl_navBarHide: Bool {
        get {
            guard let isFinished = objc_getAssociatedObject(self, &AssociatedKeys.navBarHide) as? Bool else {
                return false
            }
            return isFinished
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarHide, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if pushToCurrentVCFinished {
                navigationController?.setNavigationBarHidden(newValue, animated: true)
            }
        }
    }
    /// 当前导航栏自定义背景 view
    var vhl_navBarBackgroundView: UIView? {
        get {
            let bgView = objc_getAssociatedObject(self, &AssociatedKeys.navBarBackgroundView) as? UIView
            return bgView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarBackgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if pushToNextVCFinished == false {
                if let bgView = newValue {
                    navigationController?.setNeedsNavigationBarUpdate(backgroundView: bgView)
                }
            }
        }
    }
    /// 当前导航栏背景图片
    var vhl_navBarBackgroundImage: UIImage? {
        get {
            let bgImage = objc_getAssociatedObject(self, &AssociatedKeys.navBarBackgroundImage) as? UIImage
            return bgImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarBackgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if pushToNextVCFinished == false {
                if let bgImage = newValue {
                    navigationController?.setNeedsNavigationBarUpdate(backgroundImage: bgImage)
                }
            }
        }
    }
    /// 当前导航栏背景颜色
    var vhl_navBarBackgroundColor: UIColor {
        get {
            guard let bgColor = objc_getAssociatedObject(self, &AssociatedKeys.navBarBackgroundColor) as? UIColor else {
                return VHLNavigation.def.navBackgroundColor
            }
            return bgColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if pushToNextVCFinished == false {
                navigationController?.setNeedsNavigationBarUpdate(backgroundColor: newValue)
            }
        }
    }
    /// 当前导航栏背景透明度
    var vhl_navBarBackgroundAlpha: CGFloat {
        get {
            guard let bgColor = objc_getAssociatedObject(self, &AssociatedKeys.navBarBackgroundAlpha) as? CGFloat else {
                return 1.0
            }
            return bgColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarBackgroundAlpha, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if pushToNextVCFinished == false {
                navigationController?.setNeedsNavigationBarUpdate(backgroundAlpha: newValue)
            }
        }
    }
    /// 当前导航栏按钮颜色
    var vhl_navBarTintColor: UIColor {
        get {
            guard let tintColor = objc_getAssociatedObject(self, &AssociatedKeys.navBarTintColor) as? UIColor else {
                return VHLNavigation.def.navBarTintColor
            }
            return tintColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if pushToNextVCFinished == false {
                navigationController?.setNeedsNavigationBarUpdate(tintColor: newValue)
            }
        }
    }
    /// 当前导航栏标题颜色
    var vhl_navBarTitleColor: UIColor {
        get {
            guard let tintColor = objc_getAssociatedObject(self, &AssociatedKeys.navBarTitleColor) as? UIColor else {
                return VHLNavigation.def.navBarTitleColor
            }
            return tintColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarTitleColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if pushToNextVCFinished == false {
                navigationController?.setNeedsNavigationBarUpdate(titleColor: newValue)
            }
        }
    }
    /// 当前导航栏分割线是否隐藏
    var vhl_navBarShadowImageHide: Bool {
        get {
            guard let isFinished = objc_getAssociatedObject(self, &AssociatedKeys.navBarShadowImageHide) as? Bool else {
                return VHLNavigation.def.navBarShadowImageHidden
            }
            return isFinished
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarShadowImageHide, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if pushToNextVCFinished == false {
                self.navigationController?.setNeedsNavigationBarUpdate(hidenShadowImage: newValue)
            }
        }
    }
    /// 当前状态栏样式
    var vhl_statusBarStyle: UIStatusBarStyle {
        get {
            guard let style = objc_getAssociatedObject(self, &AssociatedKeys.statusBarStyle) as? UIStatusBarStyle else {
                return .default
            }
            return style
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.statusBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    /// 当前侧滑手势是否可用
    var vhl_interactivePopEnable: Bool {
        get {
            guard let isFinished = objc_getAssociatedObject(self, &AssociatedKeys.interactivePopEnable) as? Bool else {
                return true
            }
            return isFinished
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.interactivePopEnable, newValue, .OBJC_ASSOCIATION_ASSIGN)
            updateInteractivePopGestureRecognizer()
        }
    }
    /// 当前导航栏偏移
    var vhl_navTranslationY: CGFloat {
        get {
            let transY = objc_getAssociatedObject(self, &AssociatedKeys.navBarTranslationY) as? CGFloat ?? 0.0
            return transY
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.navBarTranslationY, newValue, .OBJC_ASSOCIATION_ASSIGN)
            self.navigationController?.navigationBar.vhl_setTranslationY(y: newValue)
        }
    }
    // MARK: - Hook methods
    private static let onceToken = UUID().uuidString
    static fileprivate func vhl_hookMethods() {
        DispatchQueue.vhl_once(token: onceToken) {
            let needSwizzleSelectors = [
                #selector(viewWillAppear(_:)),
                #selector(viewWillDisappear(_:)),
                #selector(viewDidAppear(_:)),
                #selector(viewDidDisappear(_:))
            ]
            // 交换方法
            for selector in needSwizzleSelectors{
                let newSelectorStr = "vhl_" + selector.description
                if let originalMethod = class_getInstanceMethod(self, selector),
                    let swizzledMethod = class_getInstanceMethod(self, Selector(newSelectorStr)) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }
        }
    }
    @objc private func vhl_viewWillAppear(_ animated: Bool) {
        if self.canUpdateNavigationBar() && !self.isIgnoreVC() {
            self.pushToNextVCFinished = false
            self.setNeedsStatusBarAppearanceUpdate()        // 更新状态栏
            if let navVC = self.navigationController {
                // 导航栏返回按钮
                if navVC.viewControllers.count == 1 {
                    navVC.navigationBar.vhl_setBarBackIndicatorViewIsHidden(true)
                } else {
                    navVC.navigationBar.vhl_setBarBackIndicatorViewIsHidden(false)
                }
                // 当前导航栏是否隐藏
                navVC.setNavigationBarHidden(self.vhl_navBarHide, animated: animated)
                // 恢复导航栏偏移
                self.vhl_navTranslationY = 0.0      // 修复导航栏偏移
                // 添加一个假的导航栏
                if self.shouldAddFakeNavigationBar() {
                    self.addFakeNavigationBar()
                }
                // 更新导航栏信息
                if !self.vhl_navBarHide && !self.isIgnoreVC() {
                    let isModal = (self.isMotalFrom() || self.isMotalTo())

                    // ** 当两个VC都是颜色过渡的时候，这里不设置背景，不然会闪动一下 **
                    // ** 模态跳转下，需要更新导航背景，不然有概率出现白色背景
                    if self.fakeNavBar != nil && (!self.isNavTransition() || self.isRootViewController()) || isModal {
                        self.updateNavigationBackground()
                    }
                    navVC.setNeedsNavigationBarUpdate(tintColor: self.vhl_navBarTintColor)
                    navVC.setNeedsNavigationBarUpdate(titleColor: self.vhl_navBarTitleColor)
                }
            }
        }
        // 调用自己
        vhl_viewWillAppear(animated)
    }
    @objc private func vhl_viewDidAppear(_ animated: Bool) {
        if !self.isRootViewController() { self.pushToCurrentVCFinished = true }
        self.removeFakeNavigationBar()      // 移除假的导航栏
        
        if self.canUpdateNavigationBar() {
            if let navVC = self.navigationController {
                if self.isIgnoreVC() {      // 如果是忽略的 vc
                    navVC.setNeedsNavigationBarUpdate(backgroundAlpha: 1.0)
                    navVC.setNeedsNavigationBarUpdate(tintColor: navVC.navigationBar.tintColor)
                    navVC.setNeedsNavigationBarUpdate(backgroundImage: UIImage())
                    if let barTintColor = navVC.navigationBar.barTintColor {
                        navVC.setNeedsNavigationBarUpdate(backgroundColor: barTintColor)
                    }
                } else {
                    self.updateNavigationAllInfo()
                }
            }
        }
        self.updateInteractivePopGestureRecognizer()
        // 调用自己
        vhl_viewDidAppear(animated)
    }
    @objc private func vhl_viewWillDisappear(_ animated: Bool) {
        if self.canUpdateNavigationBar() && !self.isIgnoreVC() && !self.isMotalTo() {
            // 取消隐藏导航栏
            self.navigationController?.setNavigationBarHidden(self.vhl_navBarHide, animated: animated) // self.vhl_navBarHide
            self.pushToNextVCFinished = true
        }
        // 调用自己
        vhl_viewWillDisappear(animated)
    }
    @objc private func vhl_viewDidDisappear(_ animated: Bool) {
        if self.canUpdateNavigationBar() {
            // 移除假的导航栏
            self.removeFakeNavigationBar()
            // 恢复导航栏浮动
            self.vhl_navTranslationY = 0
        }
        // 调用自己
        vhl_viewDidDisappear(animated)
    }
}
fileprivate extension UIViewController {
    // MARK: 判断当前是否能更新导航栏
    func canUpdateNavigationBar() -> Bool {
        guard let navigationController = self.navigationController else {
            return false
        }
        return navigationController.viewControllers.contains(self)
    }
    // MARK: 更新导航栏背景（背景视图/背景图片/背景颜色）
    func updateNavigationBackground() {
        if let navVC = self.navigationController {
            if let bgView = self.vhl_navBarBackgroundView {
                navVC.setNeedsNavigationBarUpdate(backgroundView: bgView)
            } else if let bgImage = self.vhl_navBarBackgroundImage {
                navVC.setNeedsNavigationBarUpdate(backgroundImage: bgImage)
            } else {
                navVC.setNeedsNavigationBarUpdate(backgroundColor: self.vhl_navBarBackgroundColor)
            }
        }
    }
    // MARK: 更新导航栏的所有属性信息
    func updateNavigationAllInfo() {
        // 背景
        updateNavigationBackground()
        // 导航栏按钮/标题/透明度/分割线
        if let navVC = self.navigationController {
            navVC.setNeedsNavigationBarUpdate(tintColor: self.vhl_navBarTintColor)
            navVC.setNeedsNavigationBarUpdate(titleColor: self.vhl_navBarTitleColor)
            navVC.setNeedsNavigationBarUpdate(backgroundAlpha: self.vhl_navBarBackgroundAlpha)
            navVC.setNeedsNavigationBarUpdate(hidenShadowImage: self.vhl_navBarShadowImageHide)
        }
    }
    // MARK: 更新侧滑手势开启关闭
    func updateInteractivePopGestureRecognizer() {
        if let navVC = self.navigationController {
            if let panRecognizer = navVC.interactivePopGestureRecognizer {
                if navVC.viewControllers.count <= 1 {
                    panRecognizer.isEnabled = false
                } else {
                    panRecognizer.isEnabled = self.vhl_interactivePopEnable
                }
            }
        }
    }
}
fileprivate extension UIViewController {
    // MARK: 导航栏是否是颜色过渡
    func isNavTransition() -> Bool {
        guard let fromVC = self.fromVC() else { return false }
        guard let toVC = self.toVC() else { return false }
        //
        if fromVC.vhl_navBarHide || toVC.vhl_navBarHide { return false }
        if fromVC.vhl_navBarBackgroundView != nil || toVC.vhl_navBarBackgroundView != nil { return false }
        if fromVC.vhl_navBarBackgroundImage != nil || toVC.vhl_navBarBackgroundImage != nil { return false }
        if fromVC.vhl_navSwitchStyle == .fakeNavBar || toVC.vhl_navSwitchStyle == .fakeNavBar { return false }
        if fromVC.vhl_navBarBackgroundAlpha != toVC.vhl_navBarBackgroundAlpha { return false }
        
        return true
    }
    // MARK: 是否是被忽略的 viewController
    func isIgnoreVC() -> Bool {
        if let selfClassName = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last {
            return VHLNavigation.def.isIgnoreVC(selfClassName)
        }
        return false
    }
}
extension UIViewController {
    // 判断当前是否是第一个视图
    func isRootViewController() -> Bool {
        if self.navigationController?.viewControllers.count ?? 0 > 1 { return false }
        
        if let rootVC = self.navigationController?.viewControllers.first {
            if rootVC.isKind(of: UITabBarController.self) {
                if let tabbarVC = rootVC as? UITabBarController {
                    return tabbarVC.viewControllers?.contains(self) ?? false
                }
            } else {
                return rootVC == self
            }
        }
        return false
    }
    /// 当前是否进行了模态跳转
    func isMotalTo() -> Bool {
        if self.presentedViewController != nil { return true }
        return false
    }
    /// 当前是否是模态跳转而来
    func isMotalFrom() -> Bool {
        if let viewControllers = self.navigationController?.viewControllers {
            if viewControllers.count > 1 {
                if viewControllers.last! == self {
                    return false
                }
            }
        }
        if self.presentingViewController != nil { return true }
        return false
    }
    
    // MARK: from VC
    func fromVC() -> UIViewController? {
        return self.navigationController?.topViewController?.transitionCoordinator?.viewController(forKey: .from)
    }
    // MARK: to VC
    func toVC() -> UIViewController? {
        return self.navigationController?.topViewController?.transitionCoordinator?.viewController(forKey: .to)
    }
    // MARK: 导航栏高度
    func statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    func navigationBarHeight() -> CGFloat {
        return self.navigationController?.navigationBar.bounds.height ?? 0.0
    }
    func navigationBarAndStatusBarHeight() -> CGFloat {
        let navHeight = self.navigationBarHeight()
        var statusHeight = self.statusBarHeight()
        // 分享热点，拨打电话等，导航栏变低
        if !VHLNavigation.isIPhoneXSeries() {
            statusHeight = min(20, statusHeight)
        }
        
        return navHeight + statusHeight
    }
}
// MARK: 假导航栏操作
fileprivate extension UIViewController {
    // MARK: 切换的导航栏自定义 View 是否一样
    func fromToVCBackgroundViewIsSame() -> Bool {
        guard let fromVC = self.fromVC() else { return false }
        guard let toVC = self.toVC() else { return false }
        
        if (fromVC.vhl_navBarBackgroundView == nil) && (toVC.vhl_navBarBackgroundView == nil) { return true }
        if (fromVC.vhl_navBarBackgroundView == nil) != (toVC.vhl_navBarBackgroundView == nil) { return false }
        if let fromBGView = fromVC.vhl_navBarBackgroundView, let toBGView = toVC.vhl_navBarBackgroundView {
            if fromBGView.classForCoder != toBGView.classForCoder { return false }
            if fromBGView.tag == 0 || fromBGView.tag != toBGView.tag { return false }
            
            return true
        }
        return false
    }
    // MARK: 判断当前是否需要添加一个假的导航栏
    func shouldAddFakeNavigationBar() -> Bool {
        guard let fromVC = self.fromVC() else { return false }
        guard let toVC = self.toVC() else { return false }
        if fromVC.isIgnoreVC() || toVC.isIgnoreVC() { return false }
        
        if fromVC.vhl_navSwitchStyle == .fakeNavBar || toVC.vhl_navSwitchStyle == .fakeNavBar { return true }
        if fromVC.vhl_navBarBackgroundImage != nil || toVC.vhl_navBarBackgroundImage != nil { return true }
        if fromVC.vhl_navBarHide != toVC.vhl_navBarHide { return true }
        if fromVC.vhl_navBarBackgroundAlpha != toVC.vhl_navBarBackgroundAlpha { return true }
        // 自定义背景 View。如果自定义 view 类型一样，且 tag 也一样，不执行假导航栏过渡
        if !self.fromToVCBackgroundViewIsSame() { return true }

        return false
    }
    // MARK: 添加一个假的导航栏
    func addFakeNavigationBar() {
        guard let fromVC = self.fromVC() else { return }
        guard let toVC = self.toVC() else { return }
        
        fromVC.removeFakeNavigationBar()
        toVC.removeFakeNavigationBar()
        
        if fromVC.isIgnoreVC() && toVC.isIgnoreVC() { return }
        
        let isTranslucent = self.navigationController?.navigationBar.isTranslucent ?? true
        
        if !fromVC.vhl_navBarHide {
            // 添加假导航栏
            var fakeNavFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationBarAndStatusBarHeight())
            if #available(iOS 13.0, *) {        // iOS 13 模态跳转
                if let navVC = self.navigationController {
                    if fromVC.isMotalFrom() && navVC.modalPresentationStyle == .pageSheet {
                        fakeNavFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationBarHeight())
                    }
                }
            }
            // 2. 判断当前 vc 是否是 UITableViewController 或 UICollectionViewController , 因为这种 vc.view 会为 scrollview
            // ** 虽然 view frame 为全屏开始，但是因为安全区域，使得内容视图在导航栏下面 **
            if fromVC.view.isKind(of: UIScrollView.self) ||
                fromVC.edgesForExtendedLayout == UIRectEdge.init(rawValue: 0) ||
                fromVC.view.bounds.height < fromVC.navigationController?.view.bounds.height ?? 0.0 {
                fakeNavFrame = fromVC.view.convert(fakeNavFrame, from: fromVC.navigationController?.view)
            }
            //
            fromVC.fakeNavBar = UIImageView(frame: fakeNavFrame)
            if let fakeNavBar = fromVC.fakeNavBar {
                if let bgView = fromVC.vhl_navBarBackgroundView {
                    fakeNavBar.backgroundColor = .clear
                    
                    /// ** 这里需要对 view 进行拷贝，避免 UINavigationBar 中对 bgView 移除操作
                    if let viewCopyData = try? NSKeyedArchiver.archivedData(withRootObject: bgView, requiringSecureCoding: false) {
//                        if let viewCopy = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIView.self, from: bgViewCopyData) {
                        if let viewCopy = NSKeyedUnarchiver.unarchiveObject(with: viewCopyData) as? UIView {
                            viewCopy.frame = fakeNavFrame
                            fakeNavBar.addSubview(viewCopy)
                        }
                    }
                } else {
                    fakeNavBar.backgroundColor = fromVC.vhl_navBarBackgroundColor
                    if #available(iOS 13.0, *) {        // iOS 13 下导航栏透明度问题
                        /// 非 .clear 的情况
                        if fromVC.vhl_navBarBackgroundColor != UIColor.clear {
                            fakeNavBar.backgroundColor = fromVC.vhl_navBarBackgroundColor.withAlphaComponent(fromVC.vhl_navBarBackgroundAlpha)
                        }
                    }
                    fakeNavBar.image = fromVC.vhl_navBarBackgroundImage
                    // 如果是忽略的VC，且默认的背景颜色有值
                    if let barTintColor = fromVC.navigationController?.navigationBar.barTintColor {
                        if fromVC.isIgnoreVC() {
                            fakeNavBar.backgroundColor = barTintColor
                        }
                    }
                }
                
                fakeNavBar.alpha = fromVC.vhl_navBarBackgroundAlpha     // 导航栏透明度
                fromVC.view.addSubview(fakeNavBar)
                fromVC.view.bringSubviewToFront(fakeNavBar)
                // 隐藏系统导航栏背景
                fromVC.navigationController?.setNeedsNavigationBarUpdate(backgroundAlpha: 0.0)
                
                // - 当从有状态栏切换到无状态栏时，会出现一个当前 vc 显示了底部 vc 的内容，这里增加一个 view 用于遮盖
                var tempFakeNavBarFrame = fakeNavFrame
                tempFakeNavBarFrame.size.height = tempFakeNavBarFrame.height + 20.0
                fromVC.tempBackView = UIView(frame: tempFakeNavBarFrame)
                if let tempBackView = fromVC.tempBackView {
                    tempBackView.backgroundColor = fromVC.view.backgroundColor
                    fromVC.view.addSubview(tempBackView)
                    fromVC.view.sendSubviewToBack(tempBackView)
                }
            }
        }
        
        if !toVC.vhl_navBarHide {
            // 添加假导航栏
            var fakeNavFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationBarAndStatusBarHeight())
            
            if #available(iOS 13.0, *) {        // iOS 13 模态跳转
                if let navVC = self.navigationController {
                    if fromVC.isMotalFrom() && navVC.modalPresentationStyle == .pageSheet {
                        fakeNavFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.navigationBarHeight())
                    }
                }
            }
            
            // 当前 fromVC 隐藏导航栏，且 isTranslucent = false 时。toVC 的 fakeNav 位置会不正确
            if fromVC.vhl_navBarHide && !isTranslucent {
                fakeNavFrame.origin.y = -fakeNavFrame.height
            }
            
            // 2. 判断当前 vc 是否是 UITableViewController 或 UICollectionViewController , 因为这种 vc.view 会为 scrollview
            // ** 虽然 view frame 为全屏开始，但是因为安全区域，使得内容视图在导航栏下面 **
            if toVC.view.isKind(of: UIScrollView.self) ||
                toVC.edgesForExtendedLayout == UIRectEdge.init(rawValue: 0) ||
                toVC.view.bounds.height < toVC.navigationController?.view.bounds.height ?? 0.0 {
                fakeNavFrame = toVC.view.convert(fakeNavFrame, from: toVC.navigationController?.view)
            }
            //
            toVC.fakeNavBar = UIImageView(frame: fakeNavFrame)
            if let fakeNavBar = toVC.fakeNavBar {
                if let bgView = toVC.vhl_navBarBackgroundView {
                    fakeNavBar.backgroundColor = .clear
                    
                    if let viewCopyData = try? NSKeyedArchiver.archivedData(withRootObject: bgView, requiringSecureCoding: false) {
//                        if let bgViewCopy = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIView.self, from: bgViewCopyData) {
                        if let viewCopy = NSKeyedUnarchiver.unarchiveObject(with: viewCopyData) as? UIView {
                            viewCopy.frame = fakeNavFrame
                            fakeNavBar.addSubview(viewCopy)
                        }
                    }
                } else {
                    fakeNavBar.backgroundColor = toVC.vhl_navBarBackgroundColor
                    if #available(iOS 13.0, *) {        // iOS 13 下导航栏透明度问题
                        /// 非 .clear 的情况
                        if toVC.vhl_navBarBackgroundColor != UIColor.clear {
                            fakeNavBar.backgroundColor = toVC.vhl_navBarBackgroundColor.withAlphaComponent(toVC.vhl_navBarBackgroundAlpha)
                        }
                    }
                    fakeNavBar.image = toVC.vhl_navBarBackgroundImage
                    // 如果是忽略的VC，且默认的背景颜色有值
                    if let barTintColor = toVC.navigationController?.navigationBar.barTintColor {
                        if toVC.isIgnoreVC() {
                            fakeNavBar.backgroundColor = barTintColor
                        }
                    }
                }
                fakeNavBar.alpha = toVC.vhl_navBarBackgroundAlpha     // 导航栏透明度
                toVC.view.addSubview(fakeNavBar)
                toVC.view.bringSubviewToFront(fakeNavBar)
                // 隐藏系统导航栏背景
                toVC.navigationController?.setNeedsNavigationBarUpdate(backgroundAlpha: 0.0)
            }
        }
    }
    // 移除假的导航栏
    func removeFakeNavigationBar() {
        if let fakeNavBar = self.fakeNavBar {
            fakeNavBar.removeFromSuperview()
            self.fakeNavBar = nil
        }
        if let tempBackView = self.tempBackView {
            tempBackView.removeFromSuperview()
            self.tempBackView = nil
        }
    }
}
// MARK: - DispatchQueue 单例执行
fileprivate extension DispatchQueue {
    private static var onceTracker = [String]()
    //Executes a block of code, associated with a unique token, only once.  The code is thread safe and will only execute the code once even in the presence of multithreaded calls.
    static func vhl_once(token: String, block: () -> Void) {   // 保证被 objc_sync_enter 和 objc_sync_exit 包裹的代码可以有序同步地执行
        objc_sync_enter(self)
        defer { // 作用域结束后执行defer中的代码
            objc_sync_exit(self)
        }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}
// MARK: - UIApplication 程序第一次运行时注入运行时注入
// 这里需要自己手动调用进行注入
extension UIApplication {
    /// ** VHLNavigation.hook()  需要将在 viewController 初始化的最前面调用 **
    static func VHLNavigationHook() {
        VHLNavigation.hook()
    }
    static let VHLNavigation_runOnce: Void = {        // 使用静态变量。用于只调用一次
        VHLNavigation.hook()
    }()
    // iOS 13.4 下因为有 UIScene 会不生效
//    open override var next: UIResponder? {
//        UIApplication.VHLNavigation_runOnce
//        return super.next
//    }
}

/**
     注意：
      1. 隐藏导航栏后，侧滑手势需要自己实现一个 UINavigationController 导航栏基类，不然侧滑手势不可用
        self.interactivePopGestureRecognizer?.delegate = self
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if self.viewControllers.count <= 1 {
                return false
            }
            return true
        }
 
      2.
 */
