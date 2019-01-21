//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension StepperFilterView {
    enum ButtonType: Int {
        case minus, plus
    }
}

public class StepperFilterView: UIControl {

    // MARK: - Public properties

    public var value: Int {
        didSet { updateUI(forValue: value) }
    }

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

    public init(filterInfo: StepperFilterInfoType) {
        self.filterInfo = filterInfo
        value = filterInfo.lowerLimit
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
            let newValue = max(filterInfo.lowerLimit, value - filterInfo.steps)
            sendActionIfNeeded(forValue: newValue)
        case .plus:
            let newValue = min(filterInfo.upperLimit, value + filterInfo.steps)
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
        if value > filterInfo.lowerLimit { textLabel.text = "\(value)+ \(filterInfo.unit)" }
        else { textLabel.text = "Alle" }
    }

    func updateButtons(forValue value: Int) {
        switch value {
        case filterInfo.lowerLimit: deactivateButton(minusButton)
        case filterInfo.upperLimit: deactivateButton(plusButton)
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
