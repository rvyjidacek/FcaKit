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
