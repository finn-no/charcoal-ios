//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

final class StepperFilterViewController: FilterViewController {
    private let filter: Filter
    private let filterInfo: StepperFilterInfo
    private lazy var topConstraint = stepperFilterView.centerYAnchor.constraint(lessThanOrEqualTo: view.topAnchor)

    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView(
            minimumValue: filterInfo.minimumValue,
            maximumValue: filterInfo.maximumValue,
            unit: filterInfo.unit
        )
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    init(filter: Filter, selectionStore: FilterSelectionStore, filterInfo: StepperFilterInfo) {
        self.filter = filter
        self.filterInfo = filterInfo
        super.init(title: filter.title, selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "apply_button_title".localized()
        view.addSubview(stepperFilterView)
        NSLayoutConstraint.activate([
            topConstraint,
            stepperFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepperFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topConstraint.constant = (view.frame.height - bottomButton.height) / 2
    }
}

// MARK: - Actions

private extension StepperFilterViewController {
    @objc func handleValueChange(sender: StepperFilterView) {
        switch sender.value {
        case filterInfo.minimumValue:
            selectionStore.removeValues(for: filter)
        default:
            selectionStore.setValue(sender.value, for: filter)
        }
        showBottomButton(true, animated: true)
    }
}
