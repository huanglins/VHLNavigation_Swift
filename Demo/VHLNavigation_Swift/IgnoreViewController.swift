//
//  IgnoreViewController.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/10/24.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class IgnoreViewController: BaseTestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "忽略的VC"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .red
    }
}
