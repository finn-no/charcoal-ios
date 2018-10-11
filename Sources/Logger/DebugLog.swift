//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

class DebugLog: NSObject {
    static func write(_ log: String) {
        #if DEBUG
            print(log)
        #endif
    }

    static func write(_ obj: AnyObject) {
        #if DEBUG
            print(obj)
        #endif
    }
}
