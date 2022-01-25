//
//  CaretsianProduct.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 29/10/2019.
//

import Foundation

public class CartesianProduct: Sequence, IteratorProtocol, CustomStringConvertible, Hashable, Equatable {
    
    public typealias Tuple = (row: Int, col: Int)
    
    public typealias Element = Tuple
    
    public var description: String { values.map { "\(tuple(for: $0))" }.description }
    
    public var count: Int { values.count }
    
    public var isEmpty: Bool { values.isEmpty }
    
    public var values: BitSet
    
    fileprivate lazy var bitsetIterator: BitsetIterator = { values.makeIterator() }()
    
    public var colsCount: Int
    
    public init(a: BitSet, b: BitSet) {
        values = BitSet(size: a.count * b.count)
        colsCount = b.size
        
        fillValues(a, b)
        
    }
    
    public init(cartesianProduct: CartesianProduct) {
        values = BitSet(bitset: cartesianProduct.values)
        colsCount = cartesianProduct.colsCount
    }
    
    public init(rows: Int, cols: Int) {
        values = BitSet(size: rows * cols)
        colsCount = cols
    }
    
    public init(context: FormalContext) {
        values = BitSet(size: context.objectCount * context.attributeCount)
        colsCount = context.values.first?.count ?? 0
                
        for row in 0..<context.values.size.rows {
            for col in 0..<colsCount {
                if context.values[row][col] == 1{
                    values.insert(index(of: (row, col)))
                }
            }
        }
    }
    
    public func erase() {
        values.erase()
    }
    
    public func insert(_ value: Tuple) {
        values.insert(index(of: value))
    }
    
    public func contains(_ value: Tuple) -> Bool {
        return values.contains(index(of: value))
    }
    
    public func intersection(_ other: CartesianProduct) {
        values.intersection(with: other.values)
    }
    
    public func intersected(_ other: CartesianProduct) -> CartesianProduct {
        let result = CartesianProduct(cartesianProduct: other)
        result.intersection(self)
        return result
    }
    
    public func union(_ other: CartesianProduct) {
        values.union(with: other.values)
    }
    
    public func unioned(_ other: CartesianProduct) -> CartesianProduct {
        let result = CartesianProduct(cartesianProduct: other)
        result.union(self)
        return result
    }
    
    public func remove(_ value: Tuple) {
        values.remove(index(of: value))
    }
    
    public func copyValues(_ other: CartesianProduct) {
        colsCount = other.colsCount
        values.setValues(to: other.values)
    }
    
    public func insert(a: BitSet, b: BitSet) {
        colsCount = b.size
        fillValues(a, b)
    }
    
    public func difference(_ other: CartesianProduct) {
        values.difference(other.values)
    }
    
    public func next() -> (row: Int, col: Int)? {
        if let value = bitsetIterator.next() { return tuple(for: value) }
        bitsetIterator = values.makeIterator()
        return nil
    }
    
    fileprivate func index(of tuple: Tuple) -> Int {
        return (tuple.row * colsCount) + tuple.col
    }
    
    fileprivate func tuple(for index: Int) -> Tuple {
        let row = index / colsCount
        let col = index - (row * colsCount)
        return (row, col)
        
    }
    
    fileprivate func fillValues(_ a: BitSet, _ b: BitSet) {
        var bValues: ContiguousArray<Int> = ContiguousArray(repeating: 0, count: b.count)
        var bValuesIndex = 0
        
        for i in b {
            bValues[bValuesIndex] = i
            bValuesIndex += 1
        }
        
        for aValue in a {
            for bValue in bValues {
                let index = self.index(of: (aValue, bValue))
                values.insert(index)
            }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        values.hash(into: &hasher)
    }
    
    public static func == (lhs: CartesianProduct, rhs: CartesianProduct) -> Bool {
        return lhs.values == rhs.values
    }
}
