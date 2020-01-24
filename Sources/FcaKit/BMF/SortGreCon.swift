//
//  SortGreCon.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 05/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//


public class SortGreCon: BMFAlgorithm {
    
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        let S = PFCbO().count(in: context)
        let U = CartesianProduct(context: context)//tuples(in: context)
        var F = [FormalConcept]()
       
        self.maxCoverTuplesIntersection = CartesianProduct(rows: context.objectCount, cols: context.attributeCount)
        
        var sortedS = S.sorted(by: {(concept1, concept2) -> Bool in
            return (concept1.attributes.count * concept1.objects.count) > (concept2.attributes.count * concept2.objects.count)
        })
        
        while !(U.isEmpty) {
            
            let result = selectMaxCover(of: U, from: sortedS)
            
            F.append(sortedS[result.index])
            
            for tuple in sortedS[result.index].cartesianProduct {
                U.remove(tuple)
            }
            
            sortedS.remove(at: result.index)
            
            
        }
        return F
    }
    
    fileprivate var maxCoverTuplesIntersection: CartesianProduct!
    
    private func selectMaxCover(of tuples: CartesianProduct, from concepts: [FormalConcept]) -> (index: Int, cover: Int) {
        maxCoverTuplesIntersection.copyValues(tuples)
        maxCoverTuplesIntersection.intersection(concepts[0].cartesianProduct)
        
        var maxCoverSize = maxCoverTuplesIntersection.count //tuples.intersection(concepts[0].tuples).count
        var maxCoverConceptIndex: Int = 0
        
        
        for i in 1..<concepts.count {
            if concepts[i].tuples.count < maxCoverSize {
                break
            } else {
                maxCoverTuplesIntersection.copyValues(tuples)
                maxCoverTuplesIntersection.intersection(concepts[i].cartesianProduct)
                
                let coverSize = maxCoverTuplesIntersection.count
                if coverSize > maxCoverSize {
                    maxCoverSize = coverSize //tuples.intersection(concepts[i].tuples).count
                    maxCoverConceptIndex = i
                }
            }
            
        }
        
        return (maxCoverConceptIndex, maxCoverSize)
    }
}

