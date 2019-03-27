//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

extension CommandLine {
    static var isUITesting: Bool {
        return arguments.contains("--uitesting")
    }
}
