//
//  TabBarViewController.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = MainViewController()
        let vc2 = DocumentsViewController()
        
        vc1.title = "Scanner"
        vc2.title = "Documents"
        
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
     
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        
        nav1.tabBarItem = UITabBarItem(title: "Scanner",
                                       image: UIImage(systemName: "scanner"),
                                       tag: 0)
        nav2.tabBarItem = UITabBarItem(title: "Documents",
                                       image: UIImage(systemName: "doc.circle"),
                                       tag: 0)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        
        setViewControllers([nav1,nav2],
                           animated: true)
    }
    

}
