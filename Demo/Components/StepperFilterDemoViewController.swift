//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

final class StepperFilterDemoViewController: DemoViewController {
    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView(
            minimumValue: 0,
            maximumValue: 6,
            unit: "stk"
        )
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stepperFilterView)
        NSLayoutConstraint.activate([
            stepperFilterView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stepperFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepperFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

private extension StepperFilterDemoViewController {
    @objc func handleValueChange(sender: StepperFilterView) {
        print("Value:", sender.value)
    }
}
