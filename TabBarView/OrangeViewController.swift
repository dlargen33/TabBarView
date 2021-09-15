//
//  OrangeViewController.swift
//  TabBarView
//
//  Created by Donald Largen on 9/13/21.
//

import UIKit
import SharedKit

class OrangeViewController: UIViewController, Reusable {

    static func get() -> OrangeViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        return storyBoard.instantiateReusableViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    


}
