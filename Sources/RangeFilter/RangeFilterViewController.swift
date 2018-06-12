//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class RangeFilterViewController: UIViewController {
    let filterInfo: RangeFilterInfoType

    public init(filterInfo: RangeFilterInfoType) {
        self.filterInfo = filterInfo
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension RangeFilterViewController {
    func setup() {
        view.backgroundColor = .milk
        title = filterInfo.name

        let range = RangeFilterView.InputRange(filterInfo.lowValue ... filterInfo.highValue)
        let rangeFilterView = RangeFilterView(range: range, steps: (range.upperBound - range.lowerBound), unit: filterInfo.unit)
        rangeFilterView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rangeFilterView)

        let safeTopAnchor: NSLayoutYAxisAnchor = {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.topAnchor
            } else {
                return view.topAnchor
            }
        }()

        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: safeTopAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .mediumSpacing),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.mediumSpacing),
        ])
    }
}
