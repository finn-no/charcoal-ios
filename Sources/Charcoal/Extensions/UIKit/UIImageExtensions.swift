//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(layer: CALayer) {
        UIGraphicsBeginImageContext(layer.frame.size)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        layer.render(in: context)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = outputImage?.cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}
