//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class ListFilterCell: CheckboxTableViewCell {
    var isEnabled = true {
        didSet {
            isUserInteractionEnabled = isEnabled
            disabledCheckbox.isHidden = isEnabled || disabledCheckbox.image == nil
            overlayView.isHidden = isEnabled
            bringSubviewToFront(overlayView)
        }
    }

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(withAutoLayout: true)
        imageView.backgroundColor = .milk
        imageView.tintColor = .chevron
        imageView.isHidden = true
        return imageView
    }()

    private lazy var disabledCheckbox: UIImageView = {
        let imageView = UIImageView(withAutoLayout: true)
        imageView.backgroundColor = .milk
        imageView.isHidden = true
        return imageView
    }()

    private lazy var overlayView: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = UIColor(white: 1, alpha: 0.5)
        view.isHidden = true
        return view
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func setSelected(_ selected: Bool, animated: Bool) {
        let isCheckboxHighlighted = checkbox.isHighlighted
        super.setSelected(selected, animated: animated)
        checkbox.isHighlighted = isCheckboxHighlighted
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let isCheckboxHighlighted = checkbox.isHighlighted
        super.setHighlighted(highlighted, animated: animated)
        checkbox.isHighlighted = isCheckboxHighlighted
    }

    override func animateSelection(isSelected: Bool) {
        super.animateSelection(isSelected: isSelected)

        guard let selectedBackgroundView = selectedBackgroundView else {
            return
        }

        insertSubview(selectedBackgroundView, at: 0)

        selectedBackgroundView.layer.removeAllAnimations()
        selectedBackgroundView.alpha = 0

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.2
        animation.fromValue = 0
        animation.toValue = 1
        animation.autoreverses = true
        animation.repeatCount = 1
        animation.delegate = self
        selectedBackgroundView.layer.add(animation, forKey: nil)
    }

    // MARK: - Setup

    func configure(with viewModel: ListFilterCellViewModel) {
        super.configure(with: viewModel)

        switch viewModel.accessoryStyle {
        case .none:
            selectionStyle = .none
            chevronImageView.isHidden = true
        case .chevron:
            selectionStyle = .default
            chevronImageView.isHidden = true
        case .external:
            selectionStyle = .default
            chevronImageView.isHidden = false
            chevronImageView.image = UIImage(named: .webview).withRenderingMode(.alwaysTemplate)
            bringSubviewToFront(chevronImageView)
        }

        switch viewModel.checkboxStyle {
        case .partiallySelected:
            checkbox.image = UIImage(named: .checkboxBordered)
            disabledCheckbox.image = UIImage(named: .checkboxBorderedDisabled)
        case .selected:
            disabledCheckbox.image = UIImage(named: .checkboxFilledDisabled)
        case .deselected:
            disabledCheckbox.image = nil
        }
    }

    private func setup() {
        titleLabel.font = .regularBody

        addSubview(chevronImageView)
        addSubview(overlayView)
        checkbox.addSubview(disabledCheckbox)

        let verticalSpacing: CGFloat = 14

        stackViewTopAnchorConstraint.constant = verticalSpacing
        stackViewBottomAnchorConstraint.constant = -verticalSpacing
        disabledCheckbox.fillInSuperview()

        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.smallSpacing * 3),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),
            chevronImageView.widthAnchor.constraint(equalTo: chevronImageView.heightAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            overlayView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

// MARK: - CAAnimationDelegate

extension ListFilterCell: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        selectedBackgroundView?.removeFromSuperview()
    }
}
