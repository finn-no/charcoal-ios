import Foundation
import CoreLocation

class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private var authorizationContinuations = [CheckedContinuation<CLAuthorizationStatus, Never>]()
    private var didSyncAuthStatus = false

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func authorizationStatus() async -> CLAuthorizationStatus {
        if didSyncAuthStatus {
            return locationManager.authorizationStatus
        }
        return await withCheckedContinuation { continuation in
            authorizationContinuations.append(continuation)
        }
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        didSyncAuthStatus = true

        for continuation in authorizationContinuations {
            continuation.resume(returning: manager.authorizationStatus)
        }
        authorizationContinuations.removeAll()
    }
}

extension CLAuthorizationStatus {
    var isLocationAuthorized: Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined, .restricted, .denied:
            return false
        @unknown default:
            return false
        }
    }
}
