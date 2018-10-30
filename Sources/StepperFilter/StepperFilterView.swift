//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension StepperFilterView {
    enum ButtonType: Int {
        case minus, plus, none
    }
}

public class StepperFilterView: UIControl {

    // MARK: - Public properties

    public var value = 1

    // MARK: - Private properties

    private let filterInfo: StepperFilterInfoType

    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "\(value)+ \(filterInfo.unit)"
        label.font = .title2
        label.textColor = .licorice
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activeColor = UIColor.primaryBlue
    private let deactiveColor = UIColor.primaryBlue.withAlphaComponent(0.2)
    private lazy var minusButton: UIButton = button(with: .minusButton, and: .minus, and: deactiveColor)
    private lazy var plusButton: UIButton = button(with: .plusButton, and: .plus, and: activeColor)

    // MARK: - Setup

    public init(filterInfo: StepperFilterInfoType) {
        self.filterInfo = filterInfo
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension StepperFilterView {
    @objc func handleButtonPressed(sender: UIButton) {
        switch sender.type {
        case .minus:
            guard value > filterInfo.lowerLimit else { return }
            value -= filterInfo.steps
            sendActions(for: .valueChanged)
        case .plus:
            guard value < filterInfo.upperLimit else { return }
            value += filterInfo.steps
            sendActions(for: .valueChanged)
        default:
            break
        }
        textLabel.text = "\(value)+ \(filterInfo.unit)"
        switch value {
        case filterInfo.lowerLimit:
            minusButton.tintColor = deactiveColor
        case filterInfo.upperLimit:
            plusButton.tintColor = deactiveColor
        default:
            minusButton.tintColor = activeColor
            plusButton.tintColor = activeColor
        }
    }

    func button(with asset: ImageAsset, and type: ButtonType, and color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = type.rawValue
        button.tintColor = color
        button.setImage(UIImage(named: asset), for: .normal)
        button.addTarget(self, action: #selector(handleButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func setup() {
        addSubview(minusButton)
        addSubview(plusButton)
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.leadingAnchor.constraint(greaterThanOrEqualTo: minusButton.trailingAnchor, constant: .smallSpacing),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: plusButton.leadingAnchor, constant: -.smallSpacing),

            minusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            minusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            minusButton.widthAnchor.constraint(equalToConstant: 58),
            minusButton.heightAnchor.constraint(equalToConstant: 58),

            plusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            plusButton.widthAnchor.constraint(equalToConstant: 58),
            plusButton.heightAnchor.constraint(equalToConstant: 58),
        ])
    }
}

extension UIButton {
    var type: StepperFilterView.ButtonType {
        return StepperFilterView.ButtonType(rawValue: tag) ?? .none
    }
}
