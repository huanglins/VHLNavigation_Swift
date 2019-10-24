//
//  BaseNavigationC.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/9/29.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class BaseNavigationC: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count <= 1 {
            return false
        }
        return true
    }
}
