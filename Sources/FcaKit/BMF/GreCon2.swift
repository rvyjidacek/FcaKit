//
//  GreCon2.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/10/2019.
//

import Foundation

public final class GreCon2: BMFAlgorithm {
    
    fileprivate typealias CoverageTuple = (conceptIndex: Int, concept: FormalConcept, coverage: Int)
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        _ = super.countFactors(in: context)
        var concepts: [FormalConcept] = []
        let conceptsArray = [FormalConcept](FCbO().count(in: context))
        var coverage: [CoverageTuple] = conceptsArray.enumerated().map { ($0, $1, $1.attributes.count * $1.objects.count) }
        var cells = createCells(from: coverage)
        
        while !(coverage.filter({ $0.coverage > 0 }).isEmpty) {
            let permutation = coverage.sorted(by: { $0.coverage > $1.coverage })
                                      .map { $0.conceptIndex }

            
            let maxValue = coverage[permutation[0]]
            
            concepts.append(maxValue.concept)
                        
            for tuple in maxValue.concept.cartesianProduct {
                let index = self.index(of: tuple)
                    
                cells[index]?.removeAll(where: { $0 == maxValue.conceptIndex })
                
                cells[index]?.forEach {
                    coverage[$0] = (coverage[$0].conceptIndex, coverage[$0].concept, coverage[$0].coverage - 1)
                }
                
                cells[index] = nil
            }
            
            
            coverage[permutation[0]] = (coverage[permutation[0]].conceptIndex,
                                        coverage[permutation[0]].concept,
                                        0)

        }
                
        return concepts
        
    }
    
    fileprivate func printCells(cells: [[Int]?]) {
        for i in 0..<cells.count {
            if !(cells[i]!.isEmpty) {
                print("\(i). \(tuple(for: i)) -> \(cells[i] ?? [])")
            }
        }
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
    
    fileprivate func index(of tuple: CartesianProduct.Tuple) -> Int {
        return (tuple.row * context.attributeCount) + tuple.col
    }
    
    fileprivate func tuple(for index: Int) -> CartesianProduct.Tuple {
        let row = index / context.attributeCount
        let col = index - (row * context.attributeCount)
        return (row, col)
        
    }
}

