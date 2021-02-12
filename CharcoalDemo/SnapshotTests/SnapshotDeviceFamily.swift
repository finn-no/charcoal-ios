import SnapshotTesting

enum SnapshotDeviceFamily: String {
    case iPhone
    case iPad

    var testDevice: ViewImageConfig {
        switch self {
        case .iPhone:
            return .iPhoneX
        case .iPad:
            return .iPadPro11(.portrait)
        }
    }
}
