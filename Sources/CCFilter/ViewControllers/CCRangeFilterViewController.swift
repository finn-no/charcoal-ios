//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class CCRangeFilterViewController: CCViewController {

    // MARK: - Private properties

    private let viewModel: RangeFilterInfo

    private lazy var rangeFilterView: RangeFilterView = {
        let view = RangeFilterView(filterInfo: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    init(filterNode: CCFilterNode, viewModel: RangeFilterInfo) {
        self.viewModel = viewModel
        super.init(filterNode: filterNode)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension CCRangeFilterViewController: RangeFilterViewDelegate {
    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetLowValue lowValue: Int?) {
        setValue(lowValue, forChildAt: CCRangeFilterNode.Index.from.rawValue)
    }

    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?) {
        setValue(highValue, forChildAt: CCRangeFilterNode.Index.to.rawValue)
    }

    private func setValue(_ value: Int?, forChildAt index: Int) {
        let childNode = filterNode.child(at: index)
        if let value = value {
            childNode.value = String(value)
            childNode.isSelected = true
        } else {
            childNode.value = nil
            childNode.isSelected = false
        }
        delegate?.viewController(self, didSelect: childNode)
        showBottomButton(true, animated: true)
    }
}

private extension CCRangeFilterViewController {
    func setup() {
        bottomButton.buttonTitle = "Bruk"

        let lowValueNode = filterNode.child(at: CCRangeFilterNode.Index.from.rawValue)
        rangeFilterView.setLowValue(Int(lowValueNode.value), animated: false)

        let highValueNode = filterNode.child(at: CCRangeFilterNode.Index.to.rawValue)
        rangeFilterView.setHighValue(Int(highValueNode.value), animated: false)

        view.addSubview(rangeFilterView)
        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rangeFilterView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }
}
