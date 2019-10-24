//
//  BaseViewController.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/9/29.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
}
extension BaseViewController {
    func getRandomColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random()) / CGFloat(UInt32.max),
        green: CGFloat(arc4random()) / CGFloat(UInt32.max),
        blue:  CGFloat(arc4random()) / CGFloat(UInt32.max),
        alpha: 1.0)
    }
}
