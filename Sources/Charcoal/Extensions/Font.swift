//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

enum FontType: String {
    case light = "FINNTypeWebStrippet-Light"
    case medium = "FINNTypeWebStrippet-Medium"
    case regular = "FINNTypeWebStrippet-Regular"
    case bold = "FINNTypeWebStrippet-Bold"
}

extension UIFont {
    static var regularBody: UIFont {
        registerCustomFonts()
        return UIFont(name: FontType.regular.rawValue, size: 16)!.scaledFont(forTextStyle: .callout)
    }
}

extension UIFont {
    static func registerFont(with filenameString: String) {
        if let bundleURL = bundle.url(forResource: "FinniversKit", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                registerFontFor(bundle: bundle, forResource: filenameString)
                return
            }
        }

        if let bundleIdentifier = bundle.bundleIdentifier {
            if let bundle = Bundle(identifier: bundleIdentifier) {
                registerFontFor(bundle: bundle, forResource: filenameString)
            }
        }
    }

    private static func registerFontFor(bundle: Bundle, forResource: String) {
        guard let pathForResourceString = bundle.path(forResource: forResource, ofType: "ttf") else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }

        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }

        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }

        guard let fontRef = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }

        var errorRef: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) == false {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }

    private static func registerCustomFonts() {
        _ = FontRegistrator.registerCustomFonts
    }
}

// https://medium.com/swift-and-ios-writing/a-quick-look-at-gcd-and-swift-3-732bef6e1838
// https://stackoverflow.com/questions/37801407/whither-dispatch-once-in-swift-3/37801408
// Registering fonts, only once instead of each time.

private final class FontRegistrator {
    static let registerCustomFonts = FontRegistrator()
    init() {
        UIFont.registerFont(with: FontType.light.rawValue)
        UIFont.registerFont(with: FontType.medium.rawValue)
        UIFont.registerFont(with: FontType.regular.rawValue)
        UIFont.registerFont(with: FontType.bold.rawValue)
    }
}
