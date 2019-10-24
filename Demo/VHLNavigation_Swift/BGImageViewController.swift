//
//  BGImageViewController.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/10/22.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class BGImageViewController: BaseTestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "背景图片"
        
        let bgImage = UIImage(named: "navbg")
        self.vhl_navBarBackgroundImage = bgImage
        // self.vhl_navBarBackgroundColor = getRandomColor()
        self.vhl_navBarTintColor = getRandomColor()
        self.vhl_navBarTitleColor = getRandomColor()
        
    }
}
