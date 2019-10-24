//
//  BGViewViewController.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/10/23.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class BGViewViewController: BaseTestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "自定义背景View(微信样式)"
        
        let blurBGColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.9)
        
        let viewBGView = UIView() //UIVisualEffectView(effect: blurEffect)
        viewBGView.frame = self.view.bounds
        viewBGView.backgroundColor = blurBGColor
        self.view.addSubview(viewBGView)
        self.view.sendSubviewToBack(viewBGView)
        
        // Do any additional setup after loading the view.
        let blurEffect = UIBlurEffect(style: .light)
        let bgView = UIVisualEffectView(effect: blurEffect)
        bgView.backgroundColor = blurBGColor
        // ** 给自定义的 View 标记tag, 如果两个 vc 的自定义view tag一样,那么不会以假导航栏样式过渡
        bgView.tag = 788 //Int(arc4random())
        self.vhl_navBarBackgroundView = bgView
        self.vhl_navBarShadowImageHide = true
        
        // --------------------------------------------------------------------------
        configSubviews()
    }
    func configSubviews() {
        for i in 0..<3 {
            let imageView = UIImageView(frame: CGRect(x: i*120, y: -10 * i, width: 120, height: 120))
            imageView.image = UIImage(named: "head")
            self.view.addSubview(imageView)
            
            let testView = UIView(frame: CGRect(x: 40, y: 40, width: 40, height: 40))
            testView.backgroundColor = getRandomColor()
            imageView.addSubview(testView)
            
            let blurEffect = UIBlurEffect(style: .light)
            let bgView = UIVisualEffectView(effect: blurEffect)
            bgView.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
            imageView.addSubview(bgView)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
