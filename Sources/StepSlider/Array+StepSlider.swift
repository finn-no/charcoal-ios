//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension Array where Element == Int {
    func findClosestStep(for value: Int?) -> StepValueResult? {
        guard let value = value, let firstInRange = first, let lastInRange = last else {
            return nil
        }

        let result: StepValueResult

        if let higherOrEqualStepIndex = firstIndex(where: { $0 >= value }) {
            let higherOrEqualStep = self[higherOrEqualStepIndex]
            let diffToHigherStep = higherOrEqualStep - value

            if diffToHigherStep == 0 {
                result = .exact(stepValue: higherOrEqualStep)
            } else if let lowerStep = self[safe: higherOrEqualStepIndex - 1] {
                let closestStep: Int
                let diffToLowerStep = lowerStep - value

                if diffToLowerStep < diffToHigherStep {
                    closestStep = lowerStep
                } else {
                    closestStep = higherOrEqualStep
                }

                result = .between(closest: closestStep, lower: lowerStep, higher: higherOrEqualStep)
            } else {
                result = .tooLow(closest: firstInRange)
            }
        } else {
            result = .tooHigh(closest: lastInRange)
        }

        return result
    }
}
