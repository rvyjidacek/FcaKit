//
//  GreCon.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 05/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class GreCon: BMFAlgorithm {

    var covered: CartesianProduct!
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        self.context = context
        var S = FCbO().count(in: context)
        let U = CartesianProduct(context: context)
        self.tuplesIntersection = CartesianProduct(context: context)
        var F = [FormalConcept]()
        let tmpCartesianProduct = CartesianProduct(rows: context.objectCount,
                                                   cols: context.attributeCount)
                
        while !(U.isEmpty) {
            let result = selectMaxCover(of: U, from: S)
            F.append(result.concept)
            S.remove(at: result.index)
            
            tmpCartesianProduct.values.erase()
            tmpCartesianProduct.insert(a: result.concept.objects,
                                       b: result.concept.attributes)
            
            for tuple in tmpCartesianProduct {
                U.remove(tuple)
            }

        }
        return F
    }
    
    
    fileprivate var tuplesIntersection: CartesianProduct!
    
    private func selectMaxCover(of tuples: CartesianProduct, from concepts: [FormalConcept]) -> (concept: FormalConcept, cover: Int, index: Int) {
        var maxCoverSize = 0
        var maxCoverConcept: FormalConcept?
        var index = -1
        
        for i in 0..<concepts.count { 
            let concept = concepts[i]
            tuplesIntersection.copyValues(tuples)
            tuplesIntersection.intersection(concept.cartesianProduct)
            let intersectionCount = tuplesIntersection.count
            
            if intersectionCount > maxCoverSize {
                maxCoverSize = intersectionCount
                maxCoverConcept = concept
                index = i
            }
        }
        return (maxCoverConcept!, maxCoverSize, index)
    }
}

