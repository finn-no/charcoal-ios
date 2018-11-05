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

    public var value = 1 {
        didSet {
            setText(withValue: value)
            updateButtons(forValue: value)
        }
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
        button.tintColor = deactiveColor
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
        super.init(frame: .zero)
        setup()
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
            guard value > filterInfo.lowerLimit else { return }
            value = max(filterInfo.lowerLimit, value - filterInfo.steps)
            sendActions(for: .valueChanged)
        case .plus:
            guard value < filterInfo.upperLimit else { return }
            value = min(filterInfo.upperLimit, value + filterInfo.steps)
            sendActions(for: .valueChanged)
        }

        setText(withValue: value)
        updateButtons(forValue: value)
    }

    func setText(withValue value: Int) {
        textLabel.text = "\(value)+ \(filterInfo.unit)"
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
