//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class PreferencesCell: UITableViewCell, Identifiable {

    var horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let preferencesView = horizontalScrollButtonGroupView {
                preferencesView.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(preferencesView)
                NSLayoutConstraint.activate([
                    preferencesView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                    preferencesView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
                    preferencesView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                    preferencesView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
                    ])
            }
        }
    }

    override var textLabel: UILabel? {
        return nil
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        accessoryType = .none
        contentView.clipsToBounds = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        horizontalScrollButtonGroupView = nil
    }
}
