//
//  BMFAlgorithm.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/10/2019.
//

open class BMFAlgorithm {
    
    public var name: String {
        let thisType = type(of: self)
        return String(describing: thisType)
    }
    
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
    
    public func countFactors(in context: FormalContext) -> [FormalConcept] {
        self.context = context
        return []
    }
}
