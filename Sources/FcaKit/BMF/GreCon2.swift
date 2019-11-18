//
//  GreCon2.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/10/2019.
//

import Foundation

public final class GreCon2: BMFAlgorithm {
    
    fileprivate typealias CoverageTuple = (conceptIndex: Int, concept: FormalConcept, coverage: Int)
    
    public override func countFactors(in context: FormalContext) -> Set<FormalConcept> {
        _ = super.countFactors(in: context)
        let concepts = FCbO().count(in: context)
        let conceptsArray = [FormalConcept](concepts)
        var coverage: [CoverageTuple] = conceptsArray.enumerated().map { ($0, $1, $1.attributes.count * $1.objects.count) }
        coverage.sort(by: { $0.coverage > $1.coverage })
        
        var cells = createCells(from: coverage)
    
        let maxValue = coverage[0]
        
        for tuple in maxValue.concept.cartesianProduct {
            let index = self.index(of: tuple)
            cells[index]?.removeAll(where: { $0 == maxValue.conceptIndex })
        }
        
        return concepts
    }
    
    fileprivate func createCells(from tuples: [CoverageTuple]) -> [[Int]?] {
        var cells = [[Int]?](repeating: [], count: context.objectCount * context.attributeCount)
        
        for coverageTuple in tuples {
            for tuple in coverageTuple.concept.cartesianProduct {
                let arrayIndex = index(of: tuple)
                cells[arrayIndex]?.append(coverageTuple.conceptIndex)
            }
        }
        
        return cells
    }
    
    fileprivate func index(of tuple: MyCartesianProduct.Tuple) -> Int {
        return (tuple.row * context.attributeCount) + tuple.col
    }
    
    fileprivate func tuple(for index: Int) -> MyCartesianProduct.Tuple {
        let row = index / context.attributeCount
        let col = index - (row * context.attributeCount)
        return (row, col)
        
    }
}

