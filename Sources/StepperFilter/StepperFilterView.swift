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
    public var value = 1
    public var steps = 1
    public var unit = "soverom"
    public var lowerLimit = 0

    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "\(value)+ \(unit)"
        label.font = .title2
        label.textColor = .licorice
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var minusButton: UIButton = button(withTitle: "—", and: .minus)
    private lazy var plusButton: UIButton = button(withTitle: "+", and: .plus)

    public override init(frame: CGRect) {
        super.init(frame: frame)
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
            guard value > lowerLimit else { return }
            value -= steps
            sendActions(for: .valueChanged)
        case .plus:
            value += steps
            sendActions(for: .valueChanged)
        default:
            break
        }
        textLabel.text = "\(value)+ \(unit)"
    }

    func button(withTitle title: String, and type: ButtonType) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = type.rawValue
        button.addTarget(self, action: #selector(handleButtonPressed(sender:)), for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.title1
        button.tintColor = .primaryBlue
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.primaryBlue.cgColor
        button.layer.cornerRadius = 29
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
