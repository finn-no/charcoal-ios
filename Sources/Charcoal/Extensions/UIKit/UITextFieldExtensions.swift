//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UITextField {
    func updateCursorAfterCharactersChange(in range: NSRange, replacementString: String, oldText: String) {
        let newText = text ?? ""
        let diff = newText.count - oldText.count
        // Consider whitespaces when two characters are being removed instead of one
        let diffWithFormatting = diff > 0 ? diff - 1 : diff + 1

        let cursorLocation = position(
            from: beginningOfDocument,
            offset: range.location + replacementString.count + diffWithFormatting
        )

        if let cursorLocation = cursorLocation {
            selectedTextRange = textRange(from: cursorLocation, to: cursorLocation)
        }
    }
}
