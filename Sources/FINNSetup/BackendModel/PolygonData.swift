//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation
import MapKit

public struct PolygonData {
    // MARK: - Polygon

    public static func createPolygonCoordinates(from query: String) -> [CLLocationCoordinate2D]? {
        guard let formattedString = query.removingPercentEncoding else { return nil }
        var coordinates = [CLLocationCoordinate2D]()
        var points = formattedString.components(separatedBy: ",")
        points.removeLast() // The same coordinate is appended on beginning and end of the query, to close the polygon.

        for point in points {
            let pointCoordinate = point.components(separatedBy: " ").compactMap { Double($0) }
            guard pointCoordinate.count == 2 else { return nil }
            coordinates.append(CLLocationCoordinate2D(
                latitude: pointCoordinate[1], longitude: pointCoordinate[0]
            ))
        }
        return coordinates
    }

    static func createPolygonQuery(for coordinates: [CLLocationCoordinate2D]) -> String? {
        guard coordinates.count > 3 else { return nil }
        var query = ""
        for coordinate in coordinates {
            query += string(for: coordinate) + ","
        }
        query += string(for: coordinates[0])
        return query
    }

    private static func string(for coordinate: CLLocationCoordinate2D) -> String {
        return String(coordinate.longitude) + " " + String(coordinate.latitude)
    }

    // MARK: - BBox

    static func createBBoxCoordinates(from query: String) -> [CLLocationCoordinate2D]? {
        guard
            let values = (query.removingPercentEncoding)?.split(separator: ",").compactMap({ Double($0) }),
            values.count == 4
        else { return nil }

        let southWestCoordinate = CLLocationCoordinate2D(latitude: values[1], longitude: values[0])
        let northEastCoordinate = CLLocationCoordinate2D(latitude: values[3], longitude: values[2])
        let northWestCoordinate = CLLocationCoordinate2D(
            latitude: southWestCoordinate.latitude, longitude: northEastCoordinate.longitude
        )
        let southEastCoordinate = CLLocationCoordinate2D(
            latitude: northEastCoordinate.latitude, longitude: southWestCoordinate.longitude
        )

        return [southWestCoordinate, northWestCoordinate, northEastCoordinate, southEastCoordinate]
    }

    static func createBBoxQuery(for coordinates: [CLLocationCoordinate2D]) -> String? {
        let bboxCoordinates = [
            coordinates.map { $0.longitude }.min() ?? 0,
            coordinates.map { $0.latitude }.min() ?? 0,
            coordinates.map { $0.longitude }.max() ?? 0,
            coordinates.map { $0.latitude }.max() ?? 0,
        ]
        guard !bboxCoordinates.contains(0) else { return nil }
        return bboxCoordinates.map { String($0) }.joined(separator: ",")
    }
}
