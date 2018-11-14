//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class CollapsedSelectionValuesView: UIView, CurrentSelectionValuesContainer {
    var delegate: CurrentSelectionValuesContainerDelegate?

    private lazy var collapsedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .title5
        label.textColor = .milk
        return label
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func configure(with selectedValues: [SelectionWithTitle]?) {
        guard let selectedValues = selectedValues else {
            collapsedLabel.text = nil
            return
        }
        let titles = selectedValues.compactMap({ $0.title })
        collapsedLabel.text = "(\(selectedValues.count)) " + titles.joined(separator: ", ")
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
