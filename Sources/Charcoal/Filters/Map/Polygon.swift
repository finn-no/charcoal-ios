//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class Polygon {

    private var edges: [PolygonEdge]

    init(edges: [PolygonEdge]) {
        self.edges = edges
    }

    func hasIntersectingEdges() -> Bool {
        for edge in edges {
            if edgeIntersects(edge) {
                return true
            }
        }
        return false
    }

    private func edgeIntersects(_ edge: PolygonEdge) -> Bool {
        var edgesToIgnore = neighborEdges(for: edge)
        edgesToIgnore.append(edge)

        for polygonEdge in edges {
            if edgesToIgnore.contains(polygonEdge) { continue }
            if edge.intersects(with: polygonEdge) {
                return true
            }
        }
        return false
    }

    private func neighborEdges(for edge: PolygonEdge) -> [PolygonEdge] {
        guard let index = edges.firstIndex(where: {$0 == edge}) else { return []}
        let previousIndex = index > 0 ? index - 1 : edges.count - 1
        let nextIndex = index + 1 < edges.count ? index + 1 : 0

        guard
            let leadingEdge = edges[safe: previousIndex],
            let trailingEdge = edges[safe: nextIndex]
        else { return [] }

        return [leadingEdge, trailingEdge]
    }
}
