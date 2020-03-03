//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

protocol RootFilterCellDelegate: AnyObject {
    func rootFilterCell(_ cell: RootFilterCell, didRemoveTagAt index: Int)
    func rootFilterCellDidRemoveAllTags(_ cell: RootFilterCell)
}

final class RootFilterCell: BasicTableViewCell {
    weak var delegate: RootFilterCellDelegate?

    override var isEnabled: Bool {
        didSet {
            isUserInteractionEnabled = isEnabled
            accessoryType = isEnabled ? .disclosureIndicator : .none

            [contextMark, titleLabel, selectionTagsContainerView].forEach {
                $0.alpha = isEnabled ? 1 : 0.4
            }
        }
    }

    var isSeparatorHidden: Bool {
        get {
            return hairLine.isHidden
        }
        set {
            hairLine.isHidden = newValue
        }
    }

    // MARK: - Private properties

    private lazy var contextMark: UIView = {
        let view = UIView(withAutoLayout: true)
        view.layer.cornerRadius = 5
        return view
    }()

    private lazy var selectionTagsContainerView: SelectionTagsContainerView = {
        let view = SelectionTagsContainerView(withAutoLayout: true)
        view.delegate = self
        return view
    }()

    private lazy var hairLine: UIView = {
        let view = UIView(withAutoLayout: true)
        view.backgroundColor = .tableViewSeparator
        return view
    }()

    private lazy var stackViewToContextMarkConstraint = stackView.leadingAnchor.constraint(
        equalTo: contextMark.trailingAnchor,
        constant: .spacingS
    )

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setContextMarkBackground()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setContextMarkBackground()
    }

    // MARK: - Setup

    func configure(withTitle title: String, selectionTitles: [SelectionTitle], isValid: Bool, style: Filter.Style = .normal) {
        titleLabel.text = title
        selectionTagsContainerView.configure(with: selectionTitles, isValid: isValid)

        switch style {
        case .normal:
            contextMark.isHidden = true
            stackViewToContextMarkConstraint.isActive = false
            stackViewLeadingAnchorConstraint.isActive = true
        case .context:
            contextMark.isHidden = false
            stackViewLeadingAnchorConstraint.isActive = false
            stackViewToContextMarkConstraint.isActive = true
        }
    }

    private func setup() {
        backgroundColor = Theme.mainBackground

        titleLabel.font = .bodyRegular
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .textPrimary

        setContextMarkBackground()

        contentView.addSubview(contextMark)
        contentView.addSubview(selectionTagsContainerView)
        contentView.addSubview(hairLine)

        stackViewLeadingAnchorConstraint.constant = .spacingM + .spacingS
        stackViewTopAnchorConstraint.constant = .spacingM
        stackViewBottomAnchorConstraint.constant = -.spacingM

        var selectionTagsContainerTrailingConstant: CGFloat = .spacingXS
        if #available(iOS 13, *) {
            selectionTagsContainerTrailingConstant -= .spacingS
        }

        NSLayoutConstraint.activate([
            contextMark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .spacingM + .spacingS),
            contextMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contextMark.widthAnchor.constraint(equalToConstant: 10),
            contextMark.heightAnchor.constraint(equalToConstant: 10),

            selectionTagsContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionTagsContainerView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: .spacingM),
            selectionTagsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: selectionTagsContainerTrailingConstant),

            hairLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            hairLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            hairLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .spacingM + .spacingS),
            hairLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func setContextMarkBackground() {
        contextMark.backgroundColor = .red
    }
}

// MARK: - SelectionTagsContainerViewDelegate

extension RootFilterCell: SelectionTagsContainerViewDelegate {
    func selectionTagsContainerView(_ view: SelectionTagsContainerView, didRemoveTagAt index: Int) {
        delegate?.rootFilterCell(self, didRemoveTagAt: index)
    }

    func selectionTagsContainerViewDidRemoveAllTags(_ view: SelectionTagsContainerView) {
        delegate?.rootFilterCellDidRemoveAllTags(self)
    }
}
