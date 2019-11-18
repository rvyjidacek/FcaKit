//
//  CaretsianProduct.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 29/10/2019.
//

import Foundation

public class MyCartesianProduct: Sequence, IteratorProtocol, CustomStringConvertible {
    
    public typealias Tuple = (row: Int, col: Int)
    
    public typealias Element = Tuple
    
    public var description: String { values.map { "\(tuple(for: $0))" }.description }
    
    var count: Int { values.count }
    
    var isEmpty: Bool { values.isEmpty }
    
    public var values: BitSet
    
    fileprivate lazy var bitsetIterator: BitsetIterator = { values.makeIterator() }()
    
    public var colsCount: Int

    
    public init(a: BitSet, b: BitSet) {
        values = BitSet(size: a.count * b.count)
        colsCount = b.size
        
        fillValues(a, b)
        
    }
    
    public init(cartesianProduct: MyCartesianProduct) {
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
    
    public func insert(_ value: Tuple) {
        values.insert(index(of: value))
    }
    
    public func intersection(_ other: MyCartesianProduct) {
        values.intersection(with: other.values)
    }
    
    public func intersected(_ other: MyCartesianProduct) -> MyCartesianProduct {
        let result = MyCartesianProduct(cartesianProduct: other)
        result.intersection(self)
        return result
    }
    
    public func remove(_ value: Tuple) {
        values.remove(index(of: value))
    }
    
    public func copyValues(_ other: MyCartesianProduct) {
        colsCount = other.colsCount
        values.setValues(to: other.values)
    }
    
    public func insert(a: BitSet, b: BitSet) {
        colsCount = b.size
        fillValues(a, b)
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
        for aValue in a {
            for bValue in b {
                let index = self.index(of: (aValue, bValue))
                values.insert(index)
            }
        }
    }
}
