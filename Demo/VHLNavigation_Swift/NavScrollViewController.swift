//
//  NavScrollViewController.swift
//  VHLNavigation_Swift
//
//  Created by Vincent on 2019/10/24.
//  Copyright © 2019 Darnel Studio. All rights reserved.
//

import UIKit

class NavScrollViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "导航栏滚动"
        self.vhl_navBarBackgroundColor = getRandomColor()
        
        // Do any additional setup after loading the view.
        let tableView = UITableView(frame: self.view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
    }
}
extension NavScrollViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.text = "\(indexPath.section) - \(indexPath.row)"
        cell?.textLabel?.textColor = getRandomColor()
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = FakeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension NavScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetY = scrollView.contentOffset.y
        if #available(iOS 11.0, *) {
             offsetY += scrollView.adjustedContentInset.top
        }
        self.vhl_navTranslationY = -offsetY
    }
}
