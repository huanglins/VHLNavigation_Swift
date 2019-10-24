//
//  FakeViewController.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/9/30.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class FakeViewController: BaseTestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "微信样式"
        
        self.vhl_navSwitchStyle = .fakeNavBar
        // 随机颜色
        self.vhl_navBarBackgroundColor = getRandomColor()
        self.vhl_navBarTintColor = getRandomColor()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
