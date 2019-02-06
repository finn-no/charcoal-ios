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
        setValue(lowValue, forChildAt: 0)
    }

    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?) {
        setValue(highValue, forChildAt: 1)
    }

    private func setValue(_ value: Int?, forChildAt index: Int) {
        guard let childNode = filterNode.children[safe: index] else { return }
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

        if let lowValue = filterNode.children[0].value {
            rangeFilterView.setLowValue(Int(lowValue), animated: false)
        } else {
            rangeFilterView.setLowValue(nil, animated: false)
        }

        if let highValue = filterNode.children[1].value {
            rangeFilterView.setHighValue(Int(highValue), animated: false)
        } else {
            rangeFilterView.setHighValue(nil, animated: false)
        }

        view.addSubview(rangeFilterView)
        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rangeFilterView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }
}
