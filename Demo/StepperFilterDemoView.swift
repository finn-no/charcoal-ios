//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

class StepperFilterDemoView: UIView {
    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView()
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stepperFilterView)
        stepperFilterView.fillInSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension StepperFilterDemoView {
    @objc func handleValueChange(sender: StepperFilterView) {
        print("Value:", sender.value)
    }
}
