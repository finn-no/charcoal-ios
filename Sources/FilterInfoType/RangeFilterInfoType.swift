//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol RangeFilterInfoType: FilterInfoType {
    var sliderData: StepSliderData<Int> { get }

    var unit: String { get }
    var isCurrencyValueRange: Bool { get }
    var accessibilitySteps: Int? { get }
    var accessibilityValueSuffix: String? { get }
    var usesSmallNumberInputFont: Bool { get }
    var displaysUnitInNumberInput: Bool { get }
}
