//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension NumberFormatter {
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    func string(from value: Int) -> String? {
        let number = NSNumber(value: value)
        return string(from: number)?.trimmingCharacters(in: .whitespaces)
    }
}
