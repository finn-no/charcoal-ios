//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

public class StepperFilterViewController: UIViewController {
    private let filterInfo: StepperFilterInfoType
    private let dataSource: FilterDataSource
    private let selectionDataSource: FilterSelectionDataSource

    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView(filterInfo: filterInfo)
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public required init(filterInfo: StepperFilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource) {
        self.filterInfo = filterInfo
        self.dataSource = dataSource
        self.selectionDataSource = selectionDataSource
        super.init(nibName: nil, bundle: nil)
        title = filterInfo.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stepperFilterView)
        stepperFilterView.fillInSuperview()

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
//            filterSelectionDelegate?.filterContainerViewControllerDidChangeSelection(filterContainerViewController: self)
        }
    }
}
