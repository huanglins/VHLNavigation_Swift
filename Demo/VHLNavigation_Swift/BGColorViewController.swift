//
//  BGColorViewController.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/10/22.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class BGColorViewController: BaseTestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "背景颜色"
        // 随机颜色
        self.vhl_navBarBackgroundColor = getRandomColor()
        self.vhl_navBarTintColor = getRandomColor()
        self.vhl_navBarTitleColor = getRandomColor()
        self.vhl_navBarShadowImageHide = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.vhl_navBarHide = !self.vhl_navBarHide
    }
}
