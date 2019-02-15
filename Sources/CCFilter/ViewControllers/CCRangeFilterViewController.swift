//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class CCRangeFilterViewController: CCViewController {

    // MARK: - Private properties

    private let rangeFilterNode: CCRangeFilterNode
    private let viewModel: RangeFilterInfo

    private lazy var rangeFilterView: RangeFilterView = {
        let view = RangeFilterView(filterInfo: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    init(rangeFilterNode: CCRangeFilterNode, viewModel: RangeFilterInfo, selectionStore: FilterSelectionStore) {
        self.rangeFilterNode = rangeFilterNode
        self.viewModel = viewModel
        super.init(filterNode: rangeFilterNode, selectionStore: selectionStore)
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
        setValue(lowValue, forChild: rangeFilterNode.lowValueNode)
    }

    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?) {
        setValue(highValue, forChild: rangeFilterNode.highValueNode)
    }

    private func setValue(_ value: Int?, forChild node: CCFilterNode) {
        selectionStore.setValue(value, for: node)
        delegate?.viewController(self, didSelect: node)
        showBottomButton(true, animated: true)
    }
}

private extension CCRangeFilterViewController {
    func setup() {
        bottomButton.buttonTitle = "apply_button_title".localized()

        let lowValue = selectionStore.value(for: rangeFilterNode.lowValueNode)
        rangeFilterView.setLowValue(Int(lowValue), animated: false)

        let highValue = selectionStore.value(for: rangeFilterNode.highValueNode)
        rangeFilterView.setHighValue(Int(highValue), animated: false)

        view.addSubview(rangeFilterView)

        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rangeFilterView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }
}
