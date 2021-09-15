//
//  ViewController.swift
//  TabBarView
//
//  Created by Donald Largen on 9/10/21.
//

import UIKit
import SharedKit

class ViewController: HHTabBarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        tabBar.unselectedItemTintColor = UIColor.lightGray
        tabBar.selectedItemTintColor = UIColor.purple
        
        tabBar.tabBarItems =  [
            HHTabBarItem(title: "Today", image: UIImage.sharedImage(named: "schedule")),
            HHTabBarItem(title: "My Projects", image: UIImage(named: "projects"))
        ]
        
        viewControllers = [ OrangeViewController.get(), TealViewController.get()]
        selectedIndex = 0
    }
}


extension ViewController: HHTabBarViewControllerDelegate {
    func tabBarController(_ tabBarController: HHTabBarViewController, didSelect viewController: UIViewController) {
        print("tab bar controller changed")
    }
    func tabBarController(_ tabBarController: HHTabBarViewController, middleButtonSelected: UIButton) {
        print("tab bar controller middle button selected.")
    }
    
}



