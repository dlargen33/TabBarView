//
//  TealViewController.swift
//  TabBarView
//
//  Created by Donald Largen on 9/13/21.
//

import UIKit
import SharedKit

class TealViewController: UIViewController, Reusable {

    static func get() -> TealViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        return storyBoard.instantiateReusableViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
