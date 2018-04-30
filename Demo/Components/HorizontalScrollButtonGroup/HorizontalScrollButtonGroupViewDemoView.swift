//
//  Copyright © 2018 FINN.no. All rights reserved.
//

import UIKit
import FilterKit

final class HorizontalScrollButtonGroupViewDemoView: UIView {
    
    lazy var demoView: HorizontalScrollButtonGroupView = {
        let view = HorizontalScrollButtonGroupView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        addSubview(demoView)
        
        NSLayoutConstraint.activate([
            demoView.topAnchor.constraint(equalTo: topAnchor, constant: .mediumLargeSpacing),
            demoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            demoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            demoView.heightAnchor.constraint(equalToConstant: HorizontalScrollButtonGroupView.defaultButtonHeight)
            ])
    }
}

extension HorizontalScrollButtonGroupViewDemoView: HorizontalScrollButtonGroupViewDataSource {
    static var titles = ["Type søk", "Tilstand", "Selger", "Publisert"]
    
    func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, titleForButtonAtIndex index: Int) -> String? {
        return HorizontalScrollButtonGroupViewDemoView.titles[index]
    }
    
    func numberOfButtons(_ horizontalScrollButtonGroup: HorizontalScrollButtonGroupView) -> Int {
        return HorizontalScrollButtonGroupViewDemoView.titles.count
    }
}

extension HorizontalScrollButtonGroupViewDemoView: HorizontalScrollButtonGroupViewDelegate {
    func horizontalScrollButtonGroupView(_ horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView, didTapButton button: UIButton, atIndex index: Int) {
        print("Button at index \(index) with title \(HorizontalScrollButtonGroupViewDemoView.titles[index]) was tapped")
        horizontalScrollButtonGroupView.setButton(at: index, selected: !button.isSelected)
    }
    

}
