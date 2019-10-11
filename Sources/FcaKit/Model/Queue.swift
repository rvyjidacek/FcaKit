//
//  Queue.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 04/10/2018.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class Queue<Element>: CustomStringConvertible, Sequence where Element: Hashable {
    
    public var description: String {
        return values.description
    }
    
    private var values: [Element]
    
    private var current: Int = 0
    
    public var isEmpty: Bool {
        return values.isEmpty
    }
    
    public var count: Int {
        return values.count
    }
    
    public init() {
        values = [Element]()
    }
    
    public init(_ sequence: Set<Element>) {
        values = [Element](sequence)
    }
    
    public init(_ sequence: [Element]) {
        values = sequence
    }
    
    public func dequeue() -> Element? {
        let first = values.first
        values = [Element](values.dropFirst())
        return first
    }
    
    public func enqueue(_ element: Element) {
        values.append(element)
    }
}


extension Queue: IteratorProtocol {
    
    public func next() -> Element? {
        if isEmpty { return nil }
        current += 1
        return values[current]
    }
    
    
    public func makeIterator() -> Queue {
        current = -1
        return self
    }
}

public indirect enum Stack<Element: Hashable>  {
    case empty
    case Node(Element, Stack<Element>)
    
    public init() { self = .empty }
    
    public init(_ value: Element) {
        self = .Node(value, .empty)
    }
    
    public mutating func push(_ value: Element) {
        self = .Node(value, self)
    }
    
    public mutating func pop() -> Element? {
        guard case let .Node(x, next) = self else { return nil }
        self = next
        return x
    }
}


public class Stack2<Element: Hashable> {
    
    private class Node<Element> {
        var value: Element
        var next: Node<Element>?
        
        init(_ value: Element, next: Node<Element>? = nil) {
            self.value = value
            self.next = next
        }
    }
    
    private var top: Node<Element>?
    
    public func push(_ value: Element) {
        self.top = top == nil ? Node<Element>(value) : Node<Element>(value, next: top)
    }
    
    public func pop() -> Element? {
        let value = top?.value
        top = top?.next
        return value
    }
    
    
}
