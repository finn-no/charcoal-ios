//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

public class StepperFilterViewController: FilterViewController {
    private let filterInfo: StepperFilterInfoType

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
        }
        showApplyButton(true)
    }
}
