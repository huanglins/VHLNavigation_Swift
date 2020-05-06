//
//  AppDelegate.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/9/29.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        VHLNavigation.hook()
        VHLNavigation.def.navBarShadowImageHidden = true
        
        let vc = BaseTestViewController()
        let navVC = BaseNavigationC(rootViewController: vc)
        window?.rootViewController = navVC
        
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle
}

