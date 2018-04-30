//
//  PopoverDemoViewController.swift
//  Demo
//
//  Created by Holmsen, Henrik on 30/04/2018.
//  Copyright © 2018 FINN.no. All rights reserved.
//

import UIKit
import FilterKit

final class PopoverDemoViewController: UIViewController {
    
    lazy var horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView = {
        let view = HorizontalScrollButtonGroupView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        view.backgroundColor = .white
        view.addSubview(horizontalScrollButtonGroupView)
        
        NSLayoutConstraint.activate([
            horizontalScrollButtonGroupView.topAnchor.constraint(equalTo: view.compatibleTopAnchor, constant: .mediumLargeSpacing),
            horizontalScrollButtonGroupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            horizontalScrollButtonGroupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            horizontalScrollButtonGroupView.heightAnchor.constraint(equalToConstant: HorizontalScrollButtonGroupView.defaultButtonHeight)
            ])
    }
}

private extension PopoverDemoViewController {
    class PopoverFilterViewController: UITableViewController {
        
        var filters = [String]()
        
        convenience init(filters: [String]) {
            self.init(style: .plain)
            self.filters = filters
            view.backgroundColor = .milk
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filters.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            cell.textLabel?.text = filters[indexPath.row]
            cell.textLabel?.font = UIFont.body
            cell.textLabel?.textColor = .primaryBlue
            return cell
        }
        
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 48
        }
    }
}

extension PopoverDemoViewController: UIPopoverPresentationControllerDelegate {
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        guard let containerView = popoverPresentationController.containerView else {
            return
        }
        
        let dimmingView = UIView(frame: containerView.frame)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0.0
        
        containerView.addSubview(dimmingView)
        
        UIView.animate(withDuration: 0.2) {
            dimmingView.alpha = 1.0
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard let selctedIndex = horizontalScrollButtonGroupView.indexesForSelectedButtons.first else {
            return
        }
        
        horizontalScrollButtonGroupView.setButton(at: selctedIndex, selected: false)
    }
}

extension PopoverDemoViewController: HorizontalScrollButtonGroupViewDataSource {
    struct Filter {
        let name: String
        let subFilters: [String]
    }
    
    static var filters: [Filter] {
        return [
            Filter(name: "Type søk", subFilters:["Til salgs", "Gis bort", "Ønskes kjøpt"]),
            Filter(name: "Tilstand", subFilters:["Alle", "Brukt", "Nytt"]),
            Filter(name: "Selger", subFilters:["Alle", "Forhandler", "Privat"]),
            Filter(name: "Publisert", subFilters:["Nye i dag"])
        ]
    }
    
    func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, titleForButtonAtIndex index: Int) -> String? {
        return PopoverDemoViewController.filters[index].name
    }
    
    func numberOfButtons(_ horizontalScrollButtonGroup: HorizontalScrollButtonGroupView) -> Int {
        return PopoverDemoViewController.filters.count
    }
}

extension PopoverDemoViewController: HorizontalScrollButtonGroupViewDelegate {
    class CustomPopoverView: UIPopoverBackgroundView {
        
        static var sourceViewSnapshotImage: UIImage?
        static var snapshotRect: CGRect = .zero
        static var snapshotParentView: UIView?
        static var preferredSize: CGSize = .zero
        
        var sourceViewSnapshot: UIImageView?
        var arrowView: UIImageView?
        
        var _arrowOffset: CGFloat = 0.0
        override var arrowOffset: CGFloat {
            get { return _arrowOffset }
            set {
                _arrowOffset = newValue
                setNeedsLayout()
            }
        }
        
        override var arrowDirection: UIPopoverArrowDirection {
            get { return .up }
            set { }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            if sourceViewSnapshot == nil {
                let frame = convert(CustomPopoverView.snapshotRect, from: CustomPopoverView.snapshotParentView)
                let imageView = UIImageView(frame: frame)
                imageView.image = CustomPopoverView.sourceViewSnapshotImage
                
                addSubview(imageView)
                
                sourceViewSnapshot = imageView
            }
            
            if arrowView == nil {
                let width = CustomPopoverView.arrowBase()
                let height = CustomPopoverView.arrowHeight()
                let x = ((self.frame.size.width / 2)  + self.arrowOffset) - (width / 2)
                let y = CustomPopoverView.contentViewInsets().top + (height / 2)
                let frame = CGRect(x: x, y: y, width: width, height: height)
                
                let arrowView = UIImageView(frame: frame)
                arrowView.backgroundColor = .milk
                addSubview(arrowView)
                
                arrowView.transform = CGAffineTransform(rotationAngle: .pi / 4)
                
                self.arrowView = arrowView
            }
            
            superview?.subviews.forEach({ $0.layer.cornerRadius = 4.0})
        }
        
        override class var wantsDefaultContentAppearance: Bool {
            return false
        }
        
        override static func contentViewInsets() -> UIEdgeInsets {
            return UIEdgeInsets(top: .verySmallSpacing, left: -9, bottom: 0, right: -9)
        }
        
        override static func arrowBase() -> CGFloat {
            return 10
        }
        
        override static func arrowHeight() -> CGFloat {
            return 10
        }
        
        deinit {
            CustomPopoverView.sourceViewSnapshotImage = nil
            CustomPopoverView.snapshotRect = .zero
            CustomPopoverView.snapshotParentView = nil
            CustomPopoverView.preferredSize = .zero
        }
        
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.frame = frame
            
            layer.masksToBounds = false
            layer.shadowColor = UIColor.clear.cgColor
            layer.shadowPath = nil
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }
    
    func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, didTapButton button: UIButton, atIndex index: Int) {
        print("Button at index \(index) with title \(HorizontalScrollButtonGroupViewDemoView.titles[index]) was tapped")
        horizontalScrollButtonGroupView.setButton(at: index, selected: !button.isSelected)
        
        let subFilters = PopoverDemoViewController.filters[index].subFilters
        let popover = PopoverFilterViewController(filters: subFilters)
        popover.preferredContentSize = CGSize(width: view.frame.size.width, height: 144)
        popover.modalPresentationStyle = .popover
    
        let popoverPresentationController = popover.popoverPresentationController
        popoverPresentationController?.permittedArrowDirections = .up
        popoverPresentationController?.delegate = self
        popoverPresentationController?.sourceView = button
        popoverPresentationController?.sourceRect = button.bounds
        popoverPresentationController?.backgroundColor = .milk
        popoverPresentationController?.popoverBackgroundViewClass = CustomPopoverView.self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: { [weak self] in
            let snapshotImage = UIImage(view: button)
            CustomPopoverView.sourceViewSnapshotImage = snapshotImage
            CustomPopoverView.snapshotRect = button.frame
            CustomPopoverView.snapshotParentView = horizontalScrollButtonGroupView
            CustomPopoverView.preferredSize = popover.preferredContentSize
          self?.present(popover, animated: true, completion: nil)
        })
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

