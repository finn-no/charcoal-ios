//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol RangeFilterInfoType: FilterInfoType {
    var sliderInfo: StepSliderInfo { get }

    var unit: String { get }
    var isCurrencyValueRange: Bool { get }
    var accessibilityValueSuffix: String? { get }
    var usesSmallNumberInputFont: Bool { get }
    var displaysUnitInNumberInput: Bool { get }
}
