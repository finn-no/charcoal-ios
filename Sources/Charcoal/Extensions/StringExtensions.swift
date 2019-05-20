//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

extension String {
    func localized(withComment comment: String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: .charcoal, value: "", comment: comment)
    }

    func removingWhitespaces() -> String {
        let components = self.components(separatedBy: .whitespaces)
        return components.joined(separator: "")
    }

    mutating func removeWhitespaces() {
        self = removingWhitespaces()
    }

    func replacementRangeNotConsideringWhitespaces(from range: NSRange,
                                                   replacementString: String) -> Range<String.Index>? {
        guard let stringRange = Range<String.Index>(range, in: self) else {
            return nil
        }

        guard String(self[stringRange]).removingWhitespaces().isEmpty, replacementString.isEmpty else {
            return stringRange
        }

        guard let lowerBound = index(stringRange.lowerBound, offsetBy: -1, limitedBy: startIndex) else {
            return stringRange
        }

        return lowerBound ..< stringRange.upperBound
    }
}
