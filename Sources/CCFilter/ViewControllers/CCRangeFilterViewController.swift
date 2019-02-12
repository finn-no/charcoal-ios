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

    init(filterNode: CCFilterNode, selectionStore: FilterSelectionStore, viewModel: RangeFilterInfo) {
        self.viewModel = viewModel
        super.init(filterNode: filterNode, selectionStore: selectionStore)
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
        guard let childNode = filterNode.child(at: index) else { return }
        if let value = value {
            selectionStore.select(node: childNode, value: String(value))
        } else {
            selectionStore.unselect(node: childNode)
        }
        delegate?.viewController(self, didSelect: childNode)
        showBottomButton(true, animated: true)
    }
}

private extension CCRangeFilterViewController {
    func setup() {
        bottomButton.buttonTitle = "Bruk"

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
