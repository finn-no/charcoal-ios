//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

struct StepValue<ValueKind: Comparable>: Equatable, Comparable, SliderReferenceValue {
    let value: ValueKind
    let displayText: String
    var isReferenceValue: Bool

    init(value: ValueKind, displayText: String, isReferenceValue: Bool = false) {
        self.value = value
        self.displayText = displayText
        self.isReferenceValue = isReferenceValue
    }

    public static func < (lhs: StepValue, rhs: StepValue) -> Bool {
        return lhs.value < rhs.value
    }
}
