//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

// Generated by generate_image_assets_symbols as a "Run Script" Build Phase
// WARNING: This file is autogenerated, do not modify by hand

import UIKit

extension UIImage {
    convenience init(named imageAsset: CharcoalImageAsset, in bundle: Bundle? = .charcoal, compatibleWith traitCollection: UITraitCollection? = nil) {
        self.init(named: imageAsset.rawValue, in: bundle, compatibleWith: traitCollection)!
    }
}

enum CharcoalImageAsset: String {
    case arrowDown
    case arrowLeft
    case arrowRight
    case checkboxBordered
    case checkboxBorderedDisabled
    case checkboxFilledDisabled
    case currentLocationIcon
    case disclosureIndicator
    case externalLink
    case homeAddressIcon
    case locateUserFilled
    case locateUserOutlined
    case minusButton
    case plusButton
    case popoverArrow
    case removeFilterValue
    case searchSmall
    case sliderThumb
    case sliderThumbActive

    public static var imageNames: [CharcoalImageAsset] {
        return [
            .arrowDown,
            .arrowLeft,
            .arrowRight,
            .checkboxBordered,
            .checkboxBorderedDisabled,
            .checkboxFilledDisabled,
            .currentLocationIcon,
            .disclosureIndicator,
            .externalLink,
            .homeAddressIcon,
            .locateUserFilled,
            .locateUserOutlined,
            .minusButton,
            .plusButton,
            .popoverArrow,
            .removeFilterValue,
            .searchSmall,
            .sliderThumb,
            .sliderThumbActive,
    ]
  }
}
