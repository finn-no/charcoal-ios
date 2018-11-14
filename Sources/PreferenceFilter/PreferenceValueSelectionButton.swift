//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

class PreferenceValueSelectionButton: UIButton {
    let preferenceValue: PreferenceValueType

    var isPreferenceValueSelected: Bool = false {
        didSet {
            if isPreferenceValueSelected {
                backgroundColor = .primaryBlue
                setTitleColor(.milk, for: .normal)
            } else {
                backgroundColor = .milk
                setTitleColor(.spaceGray, for: .normal)
            }
        }
    }

    init(preferenceValue: PreferenceValueType) {
        self.preferenceValue = preferenceValue
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .milk
        setTitleColor(.spaceGray, for: .normal)
        setTitle(preferenceValue.title, for: .normal)
        titleLabel?.font = .title4
    }
}
