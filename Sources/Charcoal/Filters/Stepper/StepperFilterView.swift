//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension StepperFilterView {
    enum ButtonType: Int {
        case minus, plus
    }
}

final class StepperFilterView: UIControl {

    // MARK: - Public properties

    var value: Int {
        didSet { updateUI(forValue: value) }
    }

    // MARK: - Private properties

    private let minimumValue: Int
    private let maximumValue: Int
    private let unit: String

    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "\(value)+ \(unit)"
        label.font = .title2
        label.textColor = .licorice
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activeColor = UIColor.primaryBlue
    private let deactiveColor = UIColor.primaryBlue.withAlphaComponent(0.2)

    private lazy var minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = activeColor
        button.setImage(UIImage(named: .minusButton), for: .normal)
        button.addTarget(self, action: #selector(minusButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = activeColor
        button.setImage(UIImage(named: .plusButton), for: .normal)
        button.addTarget(self, action: #selector(plusButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Setup

    init(minimumValue: Int, maximumValue: Int, unit: String) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.unit = unit
        value = minimumValue
        super.init(frame: .zero)
        setup()
        updateUI(forValue: value)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension StepperFilterView {
    @objc func minusButtonPressed(sender: UIButton) {
        handleButtonPressed(with: .minus)
    }

    @objc func plusButtonPressed(sender: UIButton) {
        handleButtonPressed(with: .plus)
    }

    func handleButtonPressed(with type: ButtonType) {
        switch type {
        case .minus:
            let newValue = max(minimumValue, value - 1)
            sendActionIfNeeded(forValue: newValue)
        case .plus:
            let newValue = min(maximumValue, value + 1)
            sendActionIfNeeded(forValue: newValue)
        }
    }

    func sendActionIfNeeded(forValue newValue: Int) {
        guard newValue != value else { return }
        updateUI(forValue: newValue)
        value = newValue
        sendActions(for: .valueChanged)
    }

    func updateUI(forValue value: Int) {
        setText(withValue: value)
        updateButtons(forValue: value)
    }

    func setText(withValue value: Int) {
        if value > minimumValue {
            textLabel.text = "\(value)+ \(unit)"
        } else {
            textLabel.text = "all".localized()
        }
    }

    func updateButtons(forValue value: Int) {
        switch value {
        case minimumValue: deactivateButton(minusButton)
        case maximumValue: deactivateButton(plusButton)
        default:
            activateButton(minusButton)
            activateButton(plusButton)
        }
    }

    func deactivateButton(_ button: UIButton) {
        button.tintColor = deactiveColor
        button.isUserInteractionEnabled = false
    }

    func activateButton(_ button: UIButton) {
        button.tintColor = activeColor
        button.isUserInteractionEnabled = true
    }

    func setup() {
        addSubview(minusButton)
        addSubview(plusButton)
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.leadingAnchor.constraint(greaterThanOrEqualTo: minusButton.trailingAnchor, constant: .smallSpacing),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: plusButton.leadingAnchor, constant: -.smallSpacing),

            minusButton.topAnchor.constraint(equalTo: topAnchor, constant: .mediumSpacing),
            minusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            minusButton.widthAnchor.constraint(equalToConstant: 58),
            minusButton.heightAnchor.constraint(equalToConstant: 58),
            minusButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),

            plusButton.topAnchor.constraint(equalTo: minusButton.topAnchor),
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            plusButton.widthAnchor.constraint(equalToConstant: 58),
            plusButton.heightAnchor.constraint(equalToConstant: 58),
        ])
    }
}
