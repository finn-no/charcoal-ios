//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import Warp

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
        view.backgroundColor = .border
        return view
    }()

    private lazy var stackViewToContextMarkConstraint = stackView.leadingAnchor.constraint(
        equalTo: contextMark.trailingAnchor,
        constant: Warp.Spacing.spacing100
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

        titleLabel.font = .body
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .text

        setContextMarkBackground()

        contentView.addSubview(contextMark)
        contentView.addSubview(selectionTagsContainerView)
        contentView.addSubview(hairLine)

        stackViewLeadingAnchorConstraint.constant = Warp.Spacing.spacing200 + Warp.Spacing.spacing100
        stackViewTopAnchorConstraint.constant = Warp.Spacing.spacing200
        stackViewBottomAnchorConstraint.constant = -Warp.Spacing.spacing200

        var selectionTagsContainerTrailingConstant: CGFloat = Warp.Spacing.spacing50
        selectionTagsContainerTrailingConstant -= Warp.Spacing.spacing100
        
        NSLayoutConstraint.activate([
            contextMark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Warp.Spacing.spacing200 + Warp.Spacing.spacing100),
            contextMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contextMark.widthAnchor.constraint(equalToConstant: 10),
            contextMark.heightAnchor.constraint(equalToConstant: 10),

            selectionTagsContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionTagsContainerView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Warp.Spacing.spacing200),
            selectionTagsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: selectionTagsContainerTrailingConstant),

            hairLine.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            hairLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            hairLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Warp.Spacing.spacing200 + Warp.Spacing.spacing100),
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
