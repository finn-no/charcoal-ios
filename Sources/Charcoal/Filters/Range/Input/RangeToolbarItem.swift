//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

enum RangeToolbarItem {
    case arrow(imageAsset: CharcoalImageAsset, target: UITextField?)
    case fixedSpace(width: CGFloat)
    case flexibleSpace
    case done(target: UIView)

    var buttonItem: UIBarButtonItem {
        switch self {
        case let .arrow(imageAsset, target):
            let image = UIImage(named: imageAsset)
            let button = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
            button.width = .spacingXL

            if let target = target {
                button.target = target
                button.action = #selector(UITextField.becomeFirstResponder)
            } else {
                button.isEnabled = false
            }

            return button
        case let .fixedSpace(width):
            let button = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            button.width = width
            return button
        case .flexibleSpace:
            return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        case let .done(target):
            let action = #selector(UIView.endEditing)
            let button = UIBarButtonItem(title: "done".localized(), style: .plain, target: target, action: action)
            button.setTitleTextAttributes([.font: UIFont.bodyStrong])
            return button
        }
    }
}
