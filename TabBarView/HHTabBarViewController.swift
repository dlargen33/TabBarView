//
//  HHTabBarViewController.swift
//  TabBarView
//
//  Created by Donald Largen on 9/13/21.
//

import UIKit

protocol HHTabBarViewControllerDelegate: AnyObject {
    func tabBarController(_ tabBarController: HHTabBarViewController, didSelect viewController: UIViewController)
    func tabBarController(_ tabBarController: HHTabBarViewController, middleButtonSelected: UIButton)
}

class HHTabBarViewController: UIViewController {

    private var containerView: UIView!
    private var activeViewController: UIViewController?
    private var activeConstraints:[NSLayoutConstraint]?
    private var containerBottomConstraint: NSLayoutConstraint?
    
    var tabBar: HHTabBarView!
    weak var delegate: HHTabBarViewControllerDelegate? = nil
    
    var viewControllers: [UIViewController]? {
        didSet{
            guard let _ = viewControllers else {
                tabBar.tabBarItems = nil
                return
            }
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            tabBar.selectItem(at: selectedIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor =  UIColor(named: "background")
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        
        tabBar = HHTabBarView(frame: CGRect.zero)
        tabBar.delegate = self
        
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tabBar)
        
        /* We need to store off the bottom constraint so it can be adjusted after
         the view is laid out.  This is to accout for the "arc" in the tab bar view design.
        */
        let bottomConstraint = containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tabBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tabBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tabBar.heightAnchor.constraint(equalToConstant: 116),
            tabBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bottomConstraint] )
        
        self.containerBottomConstraint = bottomConstraint
    }
    
    override func viewDidLayoutSubviews() {
        /*Adjust the botton constraint by the height of the tab bar height.
        If I could figure out how to calculate the height of the arch prior to drawing
         then I would just offset the constraint when it was added.
       */
        
        self.containerBottomConstraint?.constant = tabBar.archHeight
    }
}

extension HHTabBarViewController: HHTabBarViewDelegate {
   
    func middleButtonSelected(button: UIButton) {
        delegate?.tabBarController(self, middleButtonSelected: button)
    }
    
    func tabBarItemSelected(tabBarItem: HHTabBarItem, index: Int) {
        guard let controllers = viewControllers else { return }
        
        if let active = activeViewController {
            active.willMove(toParent: nil)
            if let constraints = activeConstraints {
                active.view.removeConstraints(constraints)
            }
            active.view.removeFromSuperview()
            active.removeFromParent()
        }
        
        let controller = controllers[index]
        addChild(controller)
        
        containerView.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints:[NSLayoutConstraint] = [
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor) ]
        NSLayoutConstraint.activate(constraints)
        
        controller.didMove(toParent: self)
        
        activeConstraints = constraints
        activeViewController = controller
        delegate?.tabBarController(self, didSelect: controller)
    }
}
