//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class InlineFilterCell: UITableViewCell {

    // MARK: - Public properties

    var delegate: InlineFilterViewDelegate? {
        get { return inlineFilterView.delegate }
        set { inlineFilterView.delegate = newValue }
    }

    private lazy var inlineFilterView: InlineFilterView = {
        let inlineFilterView = InlineFilterView()
        inlineFilterView.translatesAutoresizingMaskIntoConstraints = false
        return inlineFilterView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(withTitles titles: [[String]], vertical: String? = nil, selectedItems: [[Int]]) {
        inlineFilterView.configure(withTitles: titles, vertical: vertical, selectedItems: selectedItems)
    }

    private func setup() {
        contentView.addSubview(inlineFilterView)
        inlineFilterView.fillInSuperview(insets: UIEdgeInsets(top: 0, leading: 0, bottom: -.smallSpacing, trailing: 0))
    }
}
