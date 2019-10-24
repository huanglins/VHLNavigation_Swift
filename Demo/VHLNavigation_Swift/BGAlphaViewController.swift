//
//  BGAlphaViewController.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/10/22.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class BGAlphaViewController: BaseTestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "导航栏透明度"
        self.view.backgroundColor = .systemGreen
        
        self.vhl_navBarBackgroundAlpha = CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    // 状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        }
        return .default
    }
}
