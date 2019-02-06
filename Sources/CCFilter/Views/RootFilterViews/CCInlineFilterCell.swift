//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class CCInlineFilterCell: UITableViewCell {

    // MARK: - Public properties

    var delegate: CCInlineFilterViewDelegate? {
        get { return inlineFilterView.delegate }
        set { inlineFilterView.delegate = newValue }
    }

    private lazy var inlineFilterView: CCInlineFilterView = {
        let inlineFilterView = CCInlineFilterView()
        inlineFilterView.translatesAutoresizingMaskIntoConstraints = false
        return inlineFilterView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CCInlineFilterCell {
    func configure(with filterNode: CCFilterNode) {
        inlineFilterView.filterNode = filterNode
    }
}

private extension CCInlineFilterCell {
    func setup() {
        contentView.addSubview(inlineFilterView)
        NSLayoutConstraint.activate([
            inlineFilterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            inlineFilterView.topAnchor.constraint(equalTo: topAnchor),
            inlineFilterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            inlineFilterView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
