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

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(with segmentTitles: [[String]], vertical: String? = nil) {
        inlineFilterView.vertical = vertical
        inlineFilterView.segmentTitles = segmentTitles
    }

    private func setup() {
        contentView.addSubview(inlineFilterView)
        inlineFilterView.fillInSuperview()
    }
}
