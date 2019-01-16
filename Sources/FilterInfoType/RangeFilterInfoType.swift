//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol RangeFilterInfoType: FilterInfoType {
    var lowValue: Int { get }
    var highValue: Int { get }
    var additionalLowerBoundOffset: Int { get }
    var additionalUpperBoundOffset: Int { get }
    var stepValues: [Int] { get }
    var unit: String { get }
    var referenceValues: [Int] { get }
    var isCurrencyValueRange: Bool { get }
    var accessibilitySteps: Int? { get }
    var accessibilityValueSuffix: String? { get }
    var usesSmallNumberInputFont: Bool { get }
    var displaysUnitInNumberInput: Bool { get }
}
