//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class PolygonEdge {

    private let x: CGPoint
    private let y: CGPoint

    init(_ x: CGPoint, _ y: CGPoint) {
        self.x = x
        self.y = y
    }

    func intersects(with edge: PolygonEdge) -> Bool {
        return intersect(p1: x, p2: y, q1: edge.x, q2: edge.y)
    }

    private func intersect(p1: CGPoint, p2: CGPoint, q1: CGPoint, q2: CGPoint) -> Bool {
        return ccw(p1,q1,q2) != ccw(p2,q1,q2) && ccw(p1,p2,q1) != ccw(p1,p2,q2)
    }

    private func ccw(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
        return (c.y-a.y) * (b.x-a.x) > (b.y-a.y) * (c.x-a.x)
    }
}

extension PolygonEdge: Equatable {
    static func == (lhs: PolygonEdge, rhs: PolygonEdge) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
