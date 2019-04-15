//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

final class ListFilterCell: CheckboxTableViewCell {
    private lazy var checkboxImageView = ListFilterImageView(withAutoLayout: true)

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

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutAccessoryView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryView = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let isCheckboxHighlighted = checkbox.isHighlighted
        super.setSelected(selected, animated: animated)
        checkbox.isHighlighted = isCheckboxHighlighted
        showSelectedBackground(selected)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let isCheckboxHighlighted = checkbox.isHighlighted
        super.setHighlighted(highlighted, animated: animated)
        checkbox.isHighlighted = isCheckboxHighlighted
        showSelectedBackground(highlighted)
    }

    override func animateSelection(isSelected: Bool) {
        super.animateSelection(isSelected: isSelected)
        updateAccessibilityLabel(isSelected: isSelected)
        showSelectedBackground(!isSelected)

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.2
        animation.fromValue = 1
        animation.toValue = isSelected ? 1 : 0
        animation.autoreverses = false
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = false
        selectedBackgroundView?.layer.add(animation, forKey: nil)
    }

    private func showSelectedBackground(_ show: Bool) {
        selectedBackgroundView?.layer.removeAllAnimations()
        selectedBackgroundView?.alpha = show ? 1 : 0
    }

    // MARK: - Setup

    func configure(with viewModel: ListFilterCellViewModel) {
        super.configure(with: viewModel)

        selectionStyle = .none

        if viewModel.accessoryStyle == .external {
            let accessoryView = UIImageView(image: UIImage(named: .webview).withRenderingMode(.alwaysTemplate))
            accessoryView.tintColor = .chevron
            self.accessoryView = accessoryView
        }

        switch viewModel.checkboxStyle {
        case .selectedBordered:
            checkboxImageView.setImage(UIImage(named: .checkboxBordered), for: .normal)
            checkboxImageView.setImage(UIImage(named: .checkboxBorderedDisabled), for: .disabled)
        case .selectedFilled:
            checkboxImageView.setImage(nil, for: .normal)
            checkboxImageView.setImage(UIImage(named: .checkboxFilledDisabled), for: .disabled)
        case .deselected:
            checkboxImageView.setImage(nil, for: .normal, .disabled)
        }

        isUserInteractionEnabled = viewModel.isEnabled
        checkboxImageView.isEnabled = viewModel.isEnabled
        overlayView.isHidden = viewModel.isEnabled
        bringSubviewToFront(overlayView)

        updateAccessibilityLabel(isSelected: viewModel.checkboxStyle != .deselected)

        if let selectedBackgroundView = selectedBackgroundView, selectedBackgroundView.superview == nil {
            selectedBackgroundView.alpha = 0
            insertSubview(selectedBackgroundView, at: 0)
        }
    }

    private func setup() {
        titleLabel.font = .body

        addSubview(overlayView)
        checkbox.addSubview(checkboxImageView)

        let verticalSpacing: CGFloat = 14

        stackViewTopAnchorConstraint.constant = verticalSpacing
        stackViewBottomAnchorConstraint.constant = -verticalSpacing
        checkboxImageView.fillInSuperview()

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            overlayView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func updateAccessibilityLabel(isSelected: Bool) {
        let accessibilityLabels = [
            isSelected ? "selected".localized() : nil,
            titleLabel.text,
            subtitleLabel.text,
            detailLabel.text.map({ $0 + " " + "numberOfResults".localized() }),
        ]

        accessibilityLabel = accessibilityLabels.compactMap({ $0 }).joined(separator: ", ")
    }
}
