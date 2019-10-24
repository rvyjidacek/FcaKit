//
//  BMFAlgorithm.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/10/2019.
//

import Foundation

public class BMFAlgorithm {
    
    public init() { }
    
    func tuples(in matrix: Matrix) -> Set<Tuple> {
        var tuples: Set<Tuple> = []
        for row in 0..<matrix.count {
            for col in 0..<matrix[row].count {
                if matrix[row][col] == 1 {
                    tuples.insert(Tuple(a: row, b: col))
                }
            }
        }
        return tuples
    }
    
    public func countFactors(in matrix: Matrix) -> Set<FormalConcept> {
        return []
    }
}


public class CartesianProduct: Sequence, IteratorProtocol, CustomStringConvertible {

    public typealias Tuple = (row: Int, col: Int)
    
    public typealias Element = Tuple
    
    public var description: String { values.map { "\(indexToTuple(index: $0))" }.description }
    
    var count: Int { values.count }
    
    var isEmpty: Bool { values.isEmpty }
    
    public var values: BitSet
    
    fileprivate lazy var bitsetIterator: BitsetIterator = {
        return values.makeIterator()
    }()
    
    public var rowsCount: Int
    public var colsCount: Int
    
    public init(a: BitSet, b: BitSet) {
        values = BitSet(size: a.count * b.count)
        rowsCount = a.size
        colsCount = b.size
        
        
        let aValues = (0..<rowsCount).filter { a.contains($0) }
        let bValues = (0..<colsCount).filter { b.contains($0) }
        
        for aValue in aValues {
            for bValue in bValues {
                let index = tupleToIndex(tuple: (aValue, bValue))
                values.insert(index)
            }
        }
        
        /*
        for aValue in a {
            for bValue in b {
                let index = tupleToIndex(tuple: (aValue, bValue))
                values.insert(index)
            }
        }*/
        
    }
    
    public init(rows: Int, cols: Int) {
        values = BitSet(size: rows * cols)
        rowsCount = rows
        colsCount = cols
    }
    
    public init(matrix: Matrix) {
        values = BitSet(size: matrix.size.rows * matrix.size.columns)
        rowsCount = matrix.count
        colsCount = matrix.first?.count ?? 0
        
        //print("Matrix size: \(matrix.size), max index \(matrix.size.rows * matrix.size.columns)")
        
        for row in 0..<rowsCount {
            for col in 0..<colsCount {
                if matrix[row][col] == 1{
                    let index =  tupleToIndex(tuple: (row, col))
                    //print("Index for tuple \((row, col)) is \(index)")
                    
                    values.insert(tupleToIndex(tuple: (row, col)))
                }
            }
        }
    }
    
    public func insert(_ value: Tuple) {
        //print("insert \(value)")
        values.insert(tupleToIndex(tuple: value))
    }
    
    public func intersection(_ other: CartesianProduct) {
        values.intersection(with: other.values)
    }
    
    public func remove(_ value: Tuple) {
        values.remove(tupleToIndex(tuple: value))
    }
    
    public func copyValues(_ other: CartesianProduct) {
        rowsCount = other.rowsCount
        colsCount = other.colsCount
        values.setValues(to: other.values)
    }
    
    fileprivate func tupleToIndex(tuple: Tuple) -> Int {
        //return tuple.row * rowsCount + tuple.col
        //X + Y * Width
        return tuple.row + tuple.col * colsCount
    }
    
    fileprivate func indexToTuple(index: Int) -> Tuple {
        //let row = index / colsCount
        //return (row, index - (rowsCount * row))
        let col = index / colsCount
        let row = index - (col * colsCount)
        return (row, col)
        
    }
    
    public func next() -> (row: Int, col: Int)? {
        if let value = bitsetIterator.next() { return indexToTuple(index: value) }
        bitsetIterator = values.makeIterator()
        return nil
    }
    
    
}
