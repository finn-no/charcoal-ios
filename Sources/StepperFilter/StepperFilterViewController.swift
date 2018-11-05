//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class StepperFilterViewController: UIViewController, FilterContainerViewController {
    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?
    public var controller: UIViewController { return self }

    private let filterInfo: StepperFilterInfoType
    private let selectionDataSource: FilterSelectionDataSource

    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView(filterInfo: filterInfo)
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public required init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        guard let filterInfo = filterInfo as? StepperFilterInfoType else { return nil }
        self.filterInfo = filterInfo
        self.selectionDataSource = selectionDataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stepperFilterView)
        stepperFilterView.fillInSuperview()

        if let stringValue = selectionDataSource.value(for: filterInfo)?.first, let value = Int(stringValue) {
            stepperFilterView.value = value
        }
    }
}

private extension StepperFilterViewController {
    @objc func handleValueChange(sender: StepperFilterView) {
        selectionDataSource.setValue([String(sender.value)], for: filterInfo)
    }
}
