//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class CCRangeFilterViewController: CCViewController {

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
        if let value = value {
            selectionStore.select(node: node, value: String(value))
        } else {
            selectionStore.unselect(node: node)
        }
        delegate?.viewController(self, didSelect: node)
        showBottomButton(true, animated: true)
    }
}

private extension CCRangeFilterViewController {
    func setup() {
        bottomButton.buttonTitle = "apply_button_title".localized()

        guard let rangeNode = filterNode as? CCRangeFilterNode else {
            return
        }

        let lowValueNode = rangeNode.lowValueNode
        rangeFilterView.setLowValue(Int(lowValueNode.value), animated: false)

        let highValueNode = rangeNode.highValueNode
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
