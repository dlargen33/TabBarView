//
//  HHTabBarView.swift
//  TabBarView
//
//  Created by Donald Largen on 9/11/21.
//

import UIKit

class HHTabBarItem {
    var title: String?
    var image: UIImage?
    var button: UIButton?
    
    init( title: String?, image: UIImage?) {
        self.title = title
        self.image = image
    }
}

protocol HHTabBarViewDelegate: AnyObject {
    func tabBarItemSelected(tabBarItem: HHTabBarItem, index: Int)
    func middleButtonSelected(button: UIButton)
}

class HHTabBarView: UIView {
    
    private let radius:CGFloat = 40.0
    private var outLineLayer: CAShapeLayer? = nil
    private var middleButton: UIButton!
    private var leftContainerView: UIView = UIView(frame: CGRect.zero)
    private var rightContainerView: UIView = UIView(frame: CGRect.zero)
    
    var archHeight: CGFloat = 0.0
    
    weak var delegate:HHTabBarViewDelegate? = nil
    
    var tabBarItems: [HHTabBarItem]? {
        didSet {
            oldValue?.forEach({ item in
                item.button?.removeFromSuperview()
            })
            
            guard let items = tabBarItems else { return }
            
            if items.count > 2 {
                fatalError("Currently only supporting two tabs.  One on each side of the button")
            }
            
            for (index, item) in items.enumerated() {
                let button = UIButton(type: .custom)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle(item.title, for: .normal)
                button.tag = index
                button.addTarget(self, action: #selector(self.tabBarButtonTouched(_:)), for: .touchUpInside)
                
                if let unselectedTint = unselectedItemTintColor  {
                    if let image = item.image {
                        button.setImage(image.withTintColor(unselectedTint, renderingMode: .alwaysOriginal), for: .normal)
                    }
                    button.setTitleColor(unselectedTint, for: .normal)
                }
                    
                if let selectedTint = selectedItemTintColor {
                    if let image = item.image {
                        button.setImage(image.withTintColor(selectedTint, renderingMode: .alwaysOriginal), for: .selected)
                    }
                    button.setTitleColor(selectedTint, for: .selected)
                }
            
                let container = index == 0 ? self.leftContainerView : self.rightContainerView
                container.addSubview(button)
                
                NSLayoutConstraint.activate([
                                                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                                                button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)])
                
                button.centerVertically()
                item.button = button
            }
        }
    }
    
    var unselectedItemTintColor: UIColor? {
        didSet {
            guard let tint = unselectedItemTintColor, let items = tabBarItems else { return }
            
            items.forEach { item in
                let button = item.button
                if let image = item.image {
                    let tinted = image.withTintColor(tint, renderingMode: .alwaysOriginal)
                    button?.setImage(tinted, for: .normal)
                }
                button?.setTitleColor(tint, for: .normal)
            }
        }
    }
    
    var selectedItemTintColor: UIColor? {
        didSet {
            guard let tint = selectedItemTintColor,  let items = tabBarItems else { return }
            
            items.forEach { item in
                let button = item.button
                if let image = item.image {
                    let tinted = image.withTintColor(tint, renderingMode: .alwaysOriginal)
                    button?.setImage(tinted, for: .normal)
                }
                button?.setTitleColor(tint, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawOutLine()
    }
    
    func selectItem(at index: Int) {
        guard let items = tabBarItems,
              let selectedButton = items[index].button,
                !selectedButton.isSelected else { return }
        
        items.forEach{$0.button?.isSelected = false}
        selectedButton.isSelected = true
        delegate?.tabBarItemSelected(tabBarItem: items[index], index: index)
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clear
        
        let middle = UIButton(type: .custom)
        middle.addTarget(self, action: #selector(self.middelButtonTouched(_:)), for:.touchUpInside)
        middle.showsTouchWhenHighlighted = true
        middle.setBackgroundImage(UIImage(named: "add-ticket"), for: .normal)
        middle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(middle)
        
        NSLayoutConstraint.activate([
                                        middle.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10),
                                        middle.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        self.middleButton = middle
        
        self.leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.leftContainerView)
        NSLayoutConstraint.activate([
                                        self.leftContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                        self.leftContainerView.trailingAnchor.constraint(equalTo:self.middleButton.leadingAnchor, constant: -5),
                                        self.leftContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.archHeight),
                                        self.leftContainerView.bottomAnchor.constraint(equalTo: self.middleButton.bottomAnchor)])
        
        self.rightContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.rightContainerView)
        NSLayoutConstraint.activate([
                                        self.rightContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                        self.rightContainerView.leadingAnchor.constraint(equalTo:self.middleButton.trailingAnchor, constant: 5),
                                        self.rightContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.archHeight),
                                        self.rightContainerView.bottomAnchor.constraint(equalTo: self.middleButton.bottomAnchor)])
    }
    
    private func drawOutLine() {
        if let outline = outLineLayer {
            outline.removeFromSuperlayer()
        }
        
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        let center = self.center
        let arcCenter = CGPoint(x:center.x, y:radius)
        
        linePath.addArc(
            withCenter: arcCenter,
            radius: radius,
            startAngle: CGFloat(210.0).toRadians(),
            endAngle: CGFloat(-30.0).toRadians(),
            clockwise: true)
        
        self.archHeight = linePath.bounds.height
        linePath.addLine(to: CGPoint(x: self.frame.width , y: archHeight))
        linePath.addLine(to: CGPoint(x: self.frame.width , y: self.frame.height))
        linePath.addLine(to: CGPoint(x: 0.0 , y: self.frame.height))
        linePath.addLine(to: CGPoint(x: 0.0, y: archHeight))
        linePath.close()
        
        line.path = linePath.cgPath
        line.opacity = 1.0
        line.lineWidth = 1.0
        line.strokeColor = UIColor(named: "background")?.cgColor
        line.fillColor = UIColor.white.cgColor
        //we want this layer behind everything
        if let layers = self.layer.sublayers, layers.count > 0 {
            self.layer.sublayers?.insert(line, at: 0)
        }
        else {
            self.layer.addSublayer(line)
        }
       
        self.outLineLayer = line
    }
    
    @objc private func tabBarButtonTouched(_ button: UIButton) {
        selectItem(at: button.tag)
    }
    
    @objc private func middelButtonTouched( _ button: UIButton) {
        delegate?.middleButtonSelected(button: button)
    }
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}

extension UIButton {
    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
    
}
