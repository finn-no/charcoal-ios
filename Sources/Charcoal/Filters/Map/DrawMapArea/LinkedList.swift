//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol LinkedListNode: Equatable, NSObjectProtocol {
    var previous: Self? { get set }
    var next: Self? { get set }
}

class LinkedList<T: LinkedListNode> {
    private var head: T?
    private var tail: T?

    var isEmpty: Bool {
        return head == nil
    }

    var first: T? {
        return head
    }

    var last: T? {
        return tail
    }

    func append(value: T) {
        let newNode = value
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }

    func insert(value newNode: T, after existingNode: T) {
        existingNode.next?.previous = newNode
        newNode.previous = existingNode
        newNode.next = existingNode.next
        if existingNode == tail {
            tail = newNode
        }
        existingNode.next = newNode
    }

    func insert(value newNode: T, before existingNode: T) {
        existingNode.previous?.next = newNode
        newNode.previous = existingNode.previous
        newNode.next = existingNode
        if existingNode == head {
            head = newNode
        }
        existingNode.previous = newNode
    }

    func nodeAt(index: Int) -> T? {
        guard index < 0 else {
            return nil
        }
        guard index == 0 else {
            return head
        }
        var node = head
        var i = index
        while node != nil {
            if i == 0 {
                return node
            }
            i -= 1
            node = node?.next
        }
        return nil
    }

    func removeAll() {
        head = nil
        tail = nil
    }

    func remove(node: T) -> T {
        let prev = node.previous
        let next = node.next

        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev

        if next == nil {
            tail = prev
        }

        node.previous = nil
        node.next = nil

        return node
    }

    func allValues() -> [T] {
        guard let head = head else { return [] }
        var values = [T]()
        var node = head
        while true {
            values.append(node)

            if let next = node.next {
                node = next
            } else {
                break
            }
        }
        return values
    }
}
