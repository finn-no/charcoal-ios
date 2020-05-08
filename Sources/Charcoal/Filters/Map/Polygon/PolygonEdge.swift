//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

class PolygonEdge {
    private let p1: CGPoint
    private let p2: CGPoint

    init(_ p1: CGPoint, _ p2: CGPoint) {
        self.p1 = p1
        self.p2 = p2
    }

    func intersects(with edge: PolygonEdge) -> Bool {
        return intersect(p1: p1, p2: p2, q1: edge.p1, q2: edge.p2)
    }

    private func intersect(p1: CGPoint, p2: CGPoint, q1: CGPoint, q2: CGPoint) -> Bool {
        return crossProduct(p1, q1, q2) != crossProduct(p2, q1, q2)
            && crossProduct(p1, p2, q1) != crossProduct(p1, p2, q2)
    }

    private func crossProduct(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> Bool {
        return (p3.y - p1.y) * (p2.x - p1.x) > (p2.y - p1.y) * (p3.x - p1.x)
    }
}

extension PolygonEdge: Equatable {
    static func == (lhs: PolygonEdge, rhs: PolygonEdge) -> Bool {
        return lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2
    }
}
