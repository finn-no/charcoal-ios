//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

public class StepperFilterViewController: UIViewController, FilterContainerViewController {
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?
    public var controller: UIViewController { return self }

    private let filterInfo: StepperFilterInfoType
    private let dataSource: FilterDataSource
    private let selectionDataSource: FilterSelectionDataSource

    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView(filterInfo: filterInfo)
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public required init?(filterInfo: FilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource) {
        guard let filterInfo = filterInfo as? StepperFilterInfoType else { return nil }
        self.filterInfo = filterInfo
        self.dataSource = dataSource
        self.selectionDataSource = selectionDataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stepperFilterView)
        NSLayoutConstraint.activate([
            stepperFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepperFilterView.topAnchor.constraint(equalTo: view.topAnchor, constant: .veryLargeSpacing * 2),
            stepperFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        guard let value = selectionDataSource.stepperValue(for: filterInfo) else { return }
        stepperFilterView.value = value
    }
}

private extension StepperFilterViewController {
    @objc func handleValueChange(sender: StepperFilterView) {
        switch sender.value {
        case filterInfo.lowerLimit:
            selectionDataSource.clearAll(for: filterInfo)
        default:
            selectionDataSource.setValue(RangeValue.minimum(lowValue: sender.value), for: filterInfo)
            filterSelectionDelegate?.filterContainerViewControllerDidChangeSelection(filterContainerViewController: self)
        }
    }
}
