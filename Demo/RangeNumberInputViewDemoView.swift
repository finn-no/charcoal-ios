//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

final class RangeNumberInputViewDemoView: UIView {
    lazy var rangeNumberInputView: RangeNumberInputView = {
        let rangeNumberInputView = RangeNumberInputView(range: 0 ... 30000, unit: "kr")
        rangeNumberInputView.setLowerValue(0, animated: false)
        rangeNumberInputView.setUpperValue(30000, animated: false)
        rangeNumberInputView.translatesAutoresizingMaskIntoConstraints = false
        rangeNumberInputView.addTarget(self, action: #selector(rangeNumberInputViewValueChanged(_:)), for: .valueChanged)
        return rangeNumberInputView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        addSubview(rangeNumberInputView)

        NSLayoutConstraint.activate([
            rangeNumberInputView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rangeNumberInputView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rangeNumberInputView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    @objc func rangeNumberInputViewValueChanged(_ sender: RangeNumberInputView) {
        print("Lower value: \(sender.lowValue) -  Upper value: \(sender.highValue)")
    }
}
