//
//  GreConD.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 06/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class GreConD: BMFAlgorithm {
    
    public override func countFactors(in matrix: Matrix) -> Set<FormalConcept> {
        let context = FormalContext(values: matrix)
        var U = tuples(in: matrix)
        var F = Set<FormalConcept>()
        
        while !(U.isEmpty) {
            var D = context.attributeSet()
            var V = 0
            
            let tuples = (0..<context.attributeCount).compactMap { (attribute) -> (attribute: Int, tuples: Set<Tuple>)? in
                if D.contains(attribute) { return nil }
                return (attribute, setPlus(of: D, with: attribute, tuples: U, context: context))
            }
            
            
            if tuples.first(where: { $0.tuples.count > V }) != nil {
                let max = tuples.last(where: { $0.tuples.count > V })!.attribute
                D.insert(max)
                D = context.downAndUp(attributes: D)
                let downD = context.down(attributes: D)
                
                V = downD.cartesianProduct(with: D).intersection(U).count
                let concept = FormalConcept(objects: downD, attributes: D)
                F.insert(concept)
                
                for tuple in concept.tuples {
                    U.remove(tuple)
                }
            }
        }
        return F
    }
    
    
    private func setPlus(of attributeSet: BitSet, with attribute: Attribute, tuples: Set<Tuple>, context: FormalContext) -> Set<Tuple> {
        var a = BitSet(bitset: attributeSet)
        a.insert(attribute)
        a = context.down(attributes: a)
        
        let b = context.up(objects: a)
        
        let concept = FormalConcept(objects: a, attributes: b)
        return tuples.intersection(concept.tuples)
    }
}
