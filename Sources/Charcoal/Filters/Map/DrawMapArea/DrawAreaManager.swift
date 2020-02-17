//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

private final class SelectedMapCoordinateOverlay: NSObject, MKAnnotation, LinkedListNode {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var isHelper: Bool

    var previous: SelectedMapCoordinateOverlay?
    var next: SelectedMapCoordinateOverlay?

    init(coordinate: CLLocationCoordinate2D, isHelper: Bool = false) {
        self.coordinate = coordinate
        self.isHelper = isHelper
    }

    convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, isHelper: Bool = false) {
        self.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), isHelper: isHelper)
    }
}

final class DrawAreaManager: NSObject {
    private weak var mapView: MKMapView?
    private var startLocation = CGPoint.zero

    private var areaPolygon: MKPolygon? {
        didSet {
            if let oldValue = oldValue {
                mapView?.removeOverlay(oldValue)
            }
            if let areaPolygon = areaPolygon {
                mapView?.addOverlay(areaPolygon)
            }
        }
    }

    private var points = LinkedList<SelectedMapCoordinateOverlay>() {
        didSet {
            mapView?.removeAnnotations(oldValue.allValues())
            mapView?.addAnnotations(points.allValues())
        }
    }

    init(mapView: MKMapView) {
        self.mapView = mapView
        super.init()
        mapView.delegate = self // TODO this needs to be fixed since there already is a delegate (MapFilterViewController)
        registerMapAnnotationViews()
    }

    func startDrawing() {
        createInitialRect()
    }

    func currentCoordinates() -> [CLLocationCoordinate2D] {
        points.allValues().map { $0.coordinate }
    }

    @objc private func longPressAnnotationViewGestureHandler(_ recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: mapView)
        guard
            let annotationView = recognizer.view as? MKAnnotationView,
            let annotation = annotationView.annotation as? SelectedMapCoordinateOverlay,
            let mapView = mapView
        else { return }

        switch recognizer.state {
        case .began:
            startLocation = location
        case .changed:
            annotationView.transform = CGAffineTransform(translationX: location.x - startLocation.x, y: location.y - startLocation.y)
        case .ended, .cancelled:
            let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
            let originalLocation = mapView.convert(annotation.coordinate, toPointTo: mapView)
            let updatedLocation = CGPoint(x: originalLocation.x + translate.x, y: originalLocation.y + translate.y)

            annotationView.transform = .identity
            annotation.coordinate = mapView.convert(updatedLocation, toCoordinateFrom: mapView)

            if annotation.isHelper {
                guard let pointBefore = annotation.previous ?? points.last else { return }
                guard let pointAfter = annotation.next ?? points.first else { return }

                let helperBefore = SelectedMapCoordinateOverlay(coordinate: annotation.coordinate.middleLocationWith(location: pointBefore.coordinate), isHelper: true)
                let helperAfter = SelectedMapCoordinateOverlay(coordinate: annotation.coordinate.middleLocationWith(location: pointAfter.coordinate), isHelper: true)

                annotation.isHelper = false
                // annotationView.image = annotationsViewImage(for: annotation)
                // Refresh view
                mapView.removeAnnotation(annotation)
                mapView.addAnnotation(annotation)

                points.insert(value: helperAfter, after: annotation)
                mapView.addAnnotation(helperAfter)

                points.insert(value: helperBefore, before: annotation)
                mapView.addAnnotation(helperBefore)
            } else {
                guard let helperBefore = annotation.previous ?? points.last else { return }
                guard let helperAfter = annotation.next ?? points.first else { return }

                guard let pointBeforeHelper = helperBefore.previous ?? points.last else { return }
                guard let pointAfterHelper = helperAfter.next ?? points.first else { return }

                helperBefore.coordinate = annotation.coordinate.middleLocationWith(location: pointBeforeHelper.coordinate)
                helperAfter.coordinate = annotation.coordinate.middleLocationWith(location: pointAfterHelper.coordinate)
            }
        case .failed:
            annotationView.transform = .identity
        case .possible:
            break
        }

        drawPolygon()
    }

    private func registerMapAnnotationViews() {
        mapView?.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(SelectedMapCoordinateOverlay.self))
    }

    // MARK: -

    private func drawPolygon() {
        let coordinates = points.allValues().map { $0.coordinate }
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        areaPolygon = polygon
    }

    private func createInitialRect() {
        guard let mapView = mapView else { return }
        let pointRect = CGRect(origin: mapView.center, size: CGSize(width: 100, height: 100))
        let mapRegion = mapView.convert(pointRect, toRegionFrom: mapView)

        let top = mapRegion.center.latitude - mapRegion.span.latitudeDelta
        let bottom = mapRegion.center.latitude + mapRegion.span.latitudeDelta
        let left = mapRegion.center.longitude - mapRegion.span.longitudeDelta
        let right = mapRegion.center.longitude + mapRegion.span.longitudeDelta
        let points = LinkedList<SelectedMapCoordinateOverlay>()
        points.append(value: SelectedMapCoordinateOverlay(latitude: top, longitude: left))
        points.append(value: SelectedMapCoordinateOverlay(latitude: top, longitude: left + mapRegion.span.longitudeDelta, isHelper: true))
        points.append(value: SelectedMapCoordinateOverlay(latitude: top, longitude: right))
        points.append(value: SelectedMapCoordinateOverlay(latitude: top + mapRegion.span.latitudeDelta, longitude: right, isHelper: true))
        points.append(value: SelectedMapCoordinateOverlay(latitude: bottom, longitude: right))
        points.append(value: SelectedMapCoordinateOverlay(latitude: bottom, longitude: left + mapRegion.span.longitudeDelta, isHelper: true))
        points.append(value: SelectedMapCoordinateOverlay(latitude: bottom, longitude: left))
        points.append(value: SelectedMapCoordinateOverlay(latitude: top + mapRegion.span.latitudeDelta, longitude: left, isHelper: true))
        self.points = points
        drawPolygon()
    }

    private func annotationsViewImage(for annotation: SelectedMapCoordinateOverlay) -> UIImage {
        if annotation.isHelper {
            return UIImage(named: .sliderThumb)
        }
        return UIImage(named: .sliderThumbActive)
    }

    private func setupSelectedMapCoordinateAnnotationView(for annotation: SelectedMapCoordinateOverlay, on mapView: MKMapView) -> MKAnnotationView {
        let reuseIdentifier = NSStringFromClass(SelectedMapCoordinateOverlay.self)
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)

        annotationView.canShowCallout = false
        annotationView.image = annotationsViewImage(for: annotation)

        if let gestureRecognizers = annotationView.gestureRecognizers, gestureRecognizers.count > 0 {
            // reused
            print("reused")
        } else {
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAnnotationViewGestureHandler))
            recognizer.minimumPressDuration = 0 // set this to whatever you want
            recognizer.allowableMovement = .greatestFiniteMagnitude
            recognizer.delegate = self
            annotationView.addGestureRecognizer(recognizer)
        }
        return annotationView
    }
}

extension DrawAreaManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UILongPressGestureRecognizer && gestureRecognizer.delegate === self && otherGestureRecognizer is UILongPressGestureRecognizer
    }
}

extension DrawAreaManager: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.btnPrimary
            renderer.fillColor = UIColor.btnPrimary.withAlphaComponent(0.15)
            renderer.lineWidth = 2
            return renderer
        } else if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }

        var annotationView: MKAnnotationView?

        if let annotation = annotation as? SelectedMapCoordinateOverlay {
            annotationView = setupSelectedMapCoordinateAnnotationView(for: annotation, on: mapView)
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        drawPolygon()
    }
}

// MARK: - Private extensions

private extension CLLocationCoordinate2D {
    // MARK: CLLocationCoordinate2D+MidPoint

    func middleLocationWith(location: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lon1 = longitude * .pi / 180
        let lon2 = location.longitude * .pi / 180
        let lat1 = latitude * .pi / 180
        let lat2 = location.latitude * .pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)

        let lat3 = atan2(sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y))
        let lon3 = lon1 + atan2(y, cos(lat1) + x)

        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / .pi, lon3 * 180 / .pi)
        return center
    }
}
