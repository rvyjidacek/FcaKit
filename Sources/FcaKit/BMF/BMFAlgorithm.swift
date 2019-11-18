//
//  BMFAlgorithm.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/10/2019.
//

import Foundation

public class BMFAlgorithm {
    
    var context: FormalContext!
    
    public init() { }
    
    func tuples(in context: FormalContext) -> Set<Tuple> {
        var tuples: Set<Tuple> = []
        for row in 0..<context.values.count {
            for col in 0..<context.values[row].count {
                if context.values[row][col] == 1 {
                    tuples.insert(Tuple(a: row, b: col))
                }
            }
        }
        return tuples
    }
    
    public func countFactors(in context: FormalContext) -> Set<FormalConcept> {
        self.context = context
        return []
    }
}
