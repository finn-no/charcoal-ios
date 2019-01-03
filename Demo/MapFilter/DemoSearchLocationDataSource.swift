//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import MapKit

private struct DemoLocation: LocationInfo {
    var name: String
    var latitude: Double
    var longitude: Double
}

class DemoSearchLocationDataSource: NSObject, SearchLocationDataSource {
    private var localSearch: MKLocalSearch?

    private lazy var localSearchCompleter: NSObject? = {
        if #available(iOS 9.3, *) {
            let localSearchCompleter = MKLocalSearchCompleter()
            localSearchCompleter.delegate = self
            localSearchCompleter.filterType = .locationsOnly
            // Region that contains Norway
            localSearchCompleter.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 66.149068058495473, longitude: 17.653576306638673),
                                                             span: MKCoordinateSpan(latitudeDelta: 19.853012316209828, longitudeDelta: 28.124998591005721))
            return localSearchCompleter
        } else {
            return nil
        }
    }()

    private var searchCompletionHandler: ((SearchLocationDataSourceResult) -> Void)? {
        didSet {
            if searchCompletionHandler == nil {
                waitingLocationLookupItems.forEach({ $0.cancel() })
                waitingLocationLookupItems.removeAll()
                localSearch?.cancel()
            }
        }
    }

    private var waitingLocationLookupItems = [DispatchWorkItem]()

    private let locations = [
        DemoLocation(name: "Water", latitude: 59.00911958255264, longitude: 10.40964093117625),
        DemoLocation(name: "Countryside", latitude: 60.00227524, longitude: 10.7310662),
    ]

    func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController, didRequestLocationsFor searchQuery: String, completion: @escaping ((SearchLocationDataSourceResult) -> Void)) {
        if #available(iOS 9.3, *) {
            guard let localSearchCompleter = self.localSearchCompleter as? MKLocalSearchCompleter else {
                fatalError()
            }
            searchCompletionHandler?(.cancelled)
            searchCompletionHandler = nil
            localSearchCompleter.cancel()
            searchCompletionHandler = completion
            print("searchQuery: \(searchQuery)")
            localSearchCompleter.queryFragment = searchQuery
        } else {
            localSearch?.cancel()
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchQuery
            // Region that contains Norway
            request.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 66.149068058495473, longitude: 17.653576306638673),
                                                span: MKCoordinateSpan(latitudeDelta: 19.853012316209828, longitudeDelta: 28.124998591005721))
            localSearch = MKLocalSearch(request: request)
            localSearch?.start { response, error in
                if let error = error {
                    completion(.failed(error: error))
                } else {
                    let locations = response?.mapItems.map({ DemoLocation(name: $0.name ?? "", latitude: $0.placemark.coordinate.latitude, longitude: $0.placemark.coordinate.longitude) })
                    completion(.finished(text: searchQuery, locations: locations ?? []))
                }
            }
        }
    }

    func recentLocation(in searchLocationViewController: SearchLocationViewController) -> [LocationInfo] {
        return locations
    }

    func homeAddressLocation(in searchLocationViewController: SearchLocationViewController) -> LocationInfo? {
        return DemoLocation(name: "Grensen 5-7, Oslo", latitude: 59.91383369869115, longitude: 10.743777933233664)
    }

    func showCurrentLocation(in searchLocationViewController: SearchLocationViewController) -> Bool {
        return true
    }
}

@available(iOS 9.3, *)
extension DemoSearchLocationDataSource: MKLocalSearchCompleterDelegate {
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let locationsResult = LocationsResult()
        let group = DispatchGroup()
        // Limiting number of results to show and how fast to get it in order to avoid most throttling errors
        for (index, completion) in completer.results.prefix(3).enumerated() {
            group.enter()
            let workItem = DispatchWorkItem { [weak self] in
                self?.addLocations(for: completion, locationsResult: locationsResult, dispatchGroup: group)
            }
            waitingLocationLookupItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000 + 1000 * index), execute: workItem)
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.searchCompletionHandler?(.finished(text: completer.queryFragment, locations: locationsResult.locations))
            self?.searchCompletionHandler = nil
        }
    }

    public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    }

    private func addLocations(for completion: MKLocalSearchCompletion, locationsResult: LocationsResult, dispatchGroup: DispatchGroup) {
        let request = MKLocalSearch.Request(completion: completion)
        localSearch?.cancel()
        localSearch = MKLocalSearch(request: request)
        localSearch?.start { [weak self] response, error in
            if let error = error {
                print("\(error) - \(error.localizedDescription)")
                self?.searchCompletionHandler?(.failed(error: error))
                self?.searchCompletionHandler = nil
            } else {
                locationsResult.locations.append(contentsOf: response?.mapItems.map({ DemoLocation(name: $0.name ?? "", latitude: $0.placemark.coordinate.latitude, longitude: $0.placemark.coordinate.longitude) }) ?? [])
            }
            dispatchGroup.leave()
        }
    }
}

private class LocationsResult: NSObject {
    var locations = [LocationInfo]()
}
