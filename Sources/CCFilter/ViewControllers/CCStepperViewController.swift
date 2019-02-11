//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import UIKit

class CCStepperFilterViewController: CCViewController {
    private let viewModel: RangeFilterInfo
    private lazy var topConstraint = stepperFilterView.centerYAnchor.constraint(lessThanOrEqualTo: view.topAnchor)

    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView(filterInfo: viewModel)
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(filterNode: CCFilterNode, viewModel: RangeFilterInfo) {
        self.viewModel = viewModel
        super.init(filterNode: filterNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stepperFilterView)
        NSLayoutConstraint.activate([
            topConstraint,
            stepperFilterView.bottomAnchor.constraint(lessThanOrEqualTo: bottomButton.topAnchor),
            stepperFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepperFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topConstraint.constant = (view.frame.height - bottomButton.height) / 2
    }
}

private extension CCStepperFilterViewController {
    @objc func handleValueChange(sender: StepperFilterView) {
        switch sender.value {
        case viewModel.sliderInfo.minimumValue:
            filterNode.child(at: 0)?.value = nil
            filterNode.child(at: 0)?.isSelected = false
        default:
            filterNode.child(at: 0)?.value = String(sender.value)
            filterNode.child(at: 0)?.isSelected = true
        }
        showBottomButton(true, animated: true)
    }
}
