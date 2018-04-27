//
//  Copyright © 2018 FINN.no. All rights reserved.
//

import UIKit
import FilterKit

final class HorizontalScrollButtonGroupDemoView: UIView {
    
    lazy var demoView: HorizontalScrollButtonGroup = {
        let view = HorizontalScrollButtonGroup(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDemoView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDemoView()
    }

    func setupDemoView() {
        addSubview(demoView)
        
        NSLayoutConstraint.activate([
            demoView.topAnchor.constraint(equalTo: topAnchor, constant: .mediumLargeSpacing),
            demoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            demoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            demoView.heightAnchor.constraint(equalToConstant: HorizontalScrollButtonGroup.defaultButtonHeight)
            ])
    }
}

extension HorizontalScrollButtonGroupDemoView: HorizontalScrollButtonGroupDataSource {
    static var titles = ["Type søk", "Tilstand", "Selger", "Publisert"]
    
    func horizontalScrollButtonGroup(_ horizontalScrollButtonGroup: HorizontalScrollButtonGroup, titleForButtonAtIndex index: Int) -> String? {
        return HorizontalScrollButtonGroupDemoView.titles[index]
    }
    
    func numberOfButtons(_ horizontalScrollButtonGroup: HorizontalScrollButtonGroup) -> Int {
        return HorizontalScrollButtonGroupDemoView.titles.count
    }
}

extension HorizontalScrollButtonGroupDemoView: HorizontalScrollButtonGroupDelegate {
    func horizontalScrollButtonGroup(_ horizontalScrollButtonGroup: HorizontalScrollButtonGroup, didTapButton button: UIButton, atIndex index: Int) {
        print("Button at index \(index) with title \(HorizontalScrollButtonGroupDemoView.titles[index]) was tapped")
        horizontalScrollButtonGroup.setButton(at: index, selected: !button.isSelected)
    }
    

}
