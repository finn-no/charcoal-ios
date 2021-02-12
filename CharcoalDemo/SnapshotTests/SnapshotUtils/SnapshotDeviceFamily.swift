import SnapshotTesting

enum SnapshotDeviceFamily: String {
    case iPhone
    case iPad

    var testDevice: ViewImageConfig {
        switch self {
        case .iPhone:
            return .iPhone8
        case .iPad:
            return .iPadPro11(.portrait)
        }
    }
}
