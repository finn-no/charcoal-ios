//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class SelectionTagsCollapsedView: UIView, CurrentSelectionValuesContainer {
    var delegate: CurrentSelectionValuesContainerDelegate?

    private lazy var collapsedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .title5
        label.textColor = .milk
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    func configure(with selectedValues: [SelectionWithTitle]?) {
        guard let selectedValues = selectedValues else {
            collapsedLabel.text = nil
            return
        }
        let titlesJoined = selectedValues.compactMap({ $0.title }).joined(separator: ", ")

        if selectedValues.count > 1 {
            collapsedLabel.text = "(\(selectedValues.count)) " + titlesJoined
        } else {
            collapsedLabel.text = titlesJoined
        }
    }

    private func setup() {
        layer.cornerRadius = 4
        backgroundColor = .primaryBlue

        addSubview(collapsedLabel)

        NSLayoutConstraint.activate([
            collapsedLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            collapsedLabel.heightAnchor.constraint(equalTo: heightAnchor),
            collapsedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),
            collapsedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
        ])
    }
}
