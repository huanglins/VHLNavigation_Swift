//
//  BaseTestViewController.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/10/22.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class BaseTestViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.title = "VHLNavigation"
        configUI()
        // Do any additional setup after loading the view.
    }
    func configUI() {
        let startX = (self.view.frame.size.width - 200) / 2
        let startY: CGFloat = 72
        let itemHeight: CGFloat = 40
        let spacing: CGFloat = 12
        
        let button = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) + startY, width: 200, height: itemHeight))
        button.setTitle("微信红包样式", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        self.view.addSubview(button)
        
        let button1 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 2 + startY, width: 200, height: itemHeight))
        button1.setTitle("微信动态模糊", for: .normal)
        button1.setTitleColor(.white, for: .normal)
        button1.backgroundColor = .black
        self.view.addSubview(button1)
        
        let button2 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 3 + startY, width: 200, height: itemHeight))
        button2.setTitle("背景图片", for: .normal)
        button2.setTitleColor(.white, for: .normal)
        button2.backgroundColor = .black
        self.view.addSubview(button2)
        
        let button3 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 4 + startY, width: 200, height: itemHeight))
        button3.setTitle("背景颜色", for: .normal)
        button3.setTitleColor(.white, for: .normal)
        button3.backgroundColor = .black
        self.view.addSubview(button3)
        
        let button4 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 5 + startY, width: 200, height: itemHeight))
        button4.setTitle("背景透明度", for: .normal)
        button4.setTitleColor(.white, for: .normal)
        button4.backgroundColor = .black
        self.view.addSubview(button4)
        
        let button5 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 6 + startY, width: 200, height: itemHeight))
        button5.setTitle("导航栏隐藏", for: .normal)
        button5.setTitleColor(.white, for: .normal)
        button5.backgroundColor = .black
        self.view.addSubview(button5)
        
        let button6 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 7 + startY, width: 200, height: itemHeight))
        button6.setTitle("导航栏滚动", for: .normal)
        button6.setTitleColor(.white, for: .normal)
        button6.backgroundColor = .black
        self.view.addSubview(button6)
        
        let button7 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 8 + startY, width: 200, height: itemHeight))
        button7.setTitle("模态跳转", for: .normal)
        button7.setTitleColor(.white, for: .normal)
        button7.backgroundColor = .black
        self.view.addSubview(button7)
        
        let button8 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 9 + startY, width: 200, height: itemHeight))
        button8.setTitle("模态返回", for: .normal)
        button8.setTitleColor(.white, for: .normal)
        button8.backgroundColor = .black
        self.view.addSubview(button8)
        
        let button9 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 10 + startY, width: 200, height: itemHeight))
        button9.setTitle("忽略的VC", for: .normal)
        button9.setTitleColor(.white, for: .normal)
        button9.backgroundColor = .black
        self.view.addSubview(button9)
        
        let button10 = UIButton(frame: CGRect(x: startX, y: (itemHeight + spacing) * 11 + startY, width: 200, height: itemHeight))
        button10.setTitle("系统相册", for: .normal)
        button10.setTitleColor(.white, for: .normal)
        button10.backgroundColor = .black
        self.view.addSubview(button10)
        
        button.addTarget(self, action: #selector(wechatStyle), for: .touchUpInside)
        button1.addTarget(self, action: #selector(bgViewStyle), for: .touchUpInside)
        button2.addTarget(self, action: #selector(bgImageStyle), for: .touchUpInside)
        button3.addTarget(self, action: #selector(bgColorStyle), for: .touchUpInside)
        button4.addTarget(self, action: #selector(bgAlphaStyle), for: .touchUpInside)
        button5.addTarget(self, action: #selector(bgHideStyle), for: .touchUpInside)
        button6.addTarget(self, action: #selector(navScrollStyle), for: .touchUpInside)
        button7.addTarget(self, action: #selector(motalStyle), for: .touchUpInside)
        button8.addTarget(self, action: #selector(motalBack), for: .touchUpInside)
        button9.addTarget(self, action: #selector(ignoreVC), for: .touchUpInside)
        button10.addTarget(self, action: #selector(systemPhoto), for: .touchUpInside)
    }
    // MARK: actions
    @objc func wechatStyle() {
        let vc = FakeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func bgViewStyle() {
        let vc = BGViewViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func bgImageStyle() {
        let vc = BGImageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func bgColorStyle() {
        let vc = BGColorViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func bgAlphaStyle() {
        let vc = BGAlphaViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func bgHideStyle() {
        let vc = BGHideViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func navScrollStyle() {
        let vc = NavScrollViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func motalStyle() {
        let vc = BGViewViewController()
        let nav = BaseNavigationC(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    @objc func motalBack() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func ignoreVC() {
        VHLNavigation.def.addIgnoreVCName("IgnoreViewController")
        
        let vc = IgnoreViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func systemPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}
