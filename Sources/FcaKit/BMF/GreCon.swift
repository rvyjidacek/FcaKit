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
        
        //self.covered = CartesianProduct(rows: context.objectCount, cols: context.attributeCount)
        
        while !(U.isEmpty) {
            //covered.values.erase()
            
            let result = selectMaxCover(of: U, from: S)
            F.append(result.concept)
            S.remove(result.concept)
            
            
            /*
            for tuple in result.concept.cartesianProduct {
                covered.insert(tuple)
            }
             */
            
            tmpCartesianProduct.values.erase()
            tmpCartesianProduct.insert(a: result.concept.objects,
                                       b: result.concept.attributes)
            
            for tuple in tmpCartesianProduct { //result.concept.cartesianProduct {
                U.remove(tuple)
            }

        }
        return F
    }
    
    
    fileprivate var tuplesIntersection: CartesianProduct!
    
    private func selectMaxCover(of tuples: CartesianProduct, from concepts: Set<FormalConcept>) -> (concept: FormalConcept, cover: Int) {
        var maxCoverSize = 0
        var maxCoverConcept: FormalConcept?
        
        for concept in concepts {
            tuplesIntersection.copyValues(tuples)
            tuplesIntersection.intersection(concept.cartesianProduct)
            let intersectionCount = tuplesIntersection.count
            
            if intersectionCount > maxCoverSize {
                maxCoverSize = intersectionCount
                maxCoverConcept = concept
            }
        }
        return (maxCoverConcept!, maxCoverSize)
    }
}

