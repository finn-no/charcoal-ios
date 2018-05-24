//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import UIKit

class RangeSliderViewDemoView: UIView {
    lazy var rangeSliderView: RangeSliderView = {
        let sliderView = RangeSliderView(range: 0 ... 100, steps: 10)
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.addTarget(self, action: #selector(rangeSliderViewValueChanged(_:)), for: .valueChanged)
        return sliderView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func rangeSliderViewValueChanged(_ rangeSliderView: RangeSliderView) {
        print("Lower value: \(rangeSliderView.lowValue) -  Upper value: \(rangeSliderView.highValue)")
    }
}

private extension RangeSliderViewDemoView {
    func setup() {
        addSubview(rangeSliderView)

        NSLayoutConstraint.activate([
            rangeSliderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rangeSliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            rangeSliderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),
            rangeSliderView.heightAnchor.constraint(equalToConstant: RangeSliderView.minimumViewHeight),
        ])
    }
}
