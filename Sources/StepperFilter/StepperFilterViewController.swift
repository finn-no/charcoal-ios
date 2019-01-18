//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

public class StepperFilterViewController: FilterViewController {
    private let filterInfo: StepperFilterInfoType

    private lazy var topConstraint = stepperFilterView.centerYAnchor.constraint(lessThanOrEqualTo: view.topAnchor)

    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView(filterInfo: filterInfo)
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public init(filterInfo: StepperFilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, navigator: FilterNavigator) {
        self.filterInfo = filterInfo
        super.init(dataSource: dataSource, selectionDataSource: selectionDataSource, navigator: navigator)
        title = filterInfo.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stepperFilterView)
        NSLayoutConstraint.activate([
            topConstraint,
            stepperFilterView.bottomAnchor.constraint(lessThanOrEqualTo: applySelectionButton.topAnchor),
            stepperFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepperFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        guard let value = selectionDataSource.stepperValue(for: filterInfo) else { return }
        stepperFilterView.value = value
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topConstraint.constant = (view.frame.height - applySelectionButton.height) / 2
    }
}

private extension StepperFilterViewController {
    @objc func handleValueChange(sender: StepperFilterView) {
        switch sender.value {
        case filterInfo.lowerLimit:
            selectionDataSource.clearAll(for: filterInfo)
        default:
            selectionDataSource.setValue(RangeValue.minimum(lowValue: sender.value), for: filterInfo)
        }
        showApplyButton(true)
    }
}
