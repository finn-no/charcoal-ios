//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class PreferencesCell: UITableViewCell, Identifiable {
    private lazy var horizontalScrollButtonGroupView: HorizontalScrollButtonGroupView = {
        let view = HorizontalScrollButtonGroupView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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

    override func prepareForReuse() {
        super.prepareForReuse()
        horizontalScrollButtonGroupView.dataSource = nil
        horizontalScrollButtonGroupView.delegate = nil
    }
}

private extension PreferencesCell {
    func setup() {
        accessoryType = .none
        contentView.clipsToBounds = false

        contentView.addSubview(horizontalScrollButtonGroupView)
        NSLayoutConstraint.activate([
            horizontalScrollButtonGroupView.heightAnchor.constraint(equalToConstant: HorizontalScrollButtonGroupView.defaultButtonHeight),
            horizontalScrollButtonGroupView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            horizontalScrollButtonGroupView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            horizontalScrollButtonGroupView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            horizontalScrollButtonGroupView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ])
    }
}

extension PreferencesCell {
    var horizontalScrollButtonGroupViewDataSource: HorizontalScrollButtonGroupViewDataSource? {
        get {
            return horizontalScrollButtonGroupView.dataSource
        }
        set {
            horizontalScrollButtonGroupView.dataSource = newValue
        }
    }

    var horizontalScrollButtonGroupViewDelegate: HorizontalScrollButtonGroupViewDelegate? {
        get {
            return horizontalScrollButtonGroupView.delegate
        }
        set {
            horizontalScrollButtonGroupView.delegate = newValue
        }
    }
}
