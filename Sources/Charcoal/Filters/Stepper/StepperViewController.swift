//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

final class StepperFilterViewController: FilterViewController {
    private let filter: Filter
    private let filterConfig: StepperFilterConfiguration
    private lazy var topConstraint = stepperFilterView.centerYAnchor.constraint(lessThanOrEqualTo: view.topAnchor)

    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView(
            minimumValue: filterConfig.minimumValue,
            maximumValue: filterConfig.maximumValue,
            unit: filterConfig.unit
        )
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    init(filter: Filter, selectionStore: FilterSelectionStore, filterConfig: StepperFilterConfiguration) {
        self.filter = filter
        self.filterConfig = filterConfig
        super.init(title: filter.title, selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "applyButton".localized()

        if let value: Int = selectionStore.value(for: filter) {
            stepperFilterView.value = value
        }

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
        case filterConfig.minimumValue:
            selectionStore.removeValues(for: filter)
        default:
            selectionStore.setValue(sender.value, for: filter)
        }
        showBottomButton(true, animated: true)
    }
}
