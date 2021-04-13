//
//  GreCon2.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/10/2019.
//


public final class GreCon2: BMFAlgorithm {
    
    fileprivate typealias CoverageTuple = (conceptIndex: Int, concept: Bicluster, coverage: Int)
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        return countFactorization(using: FCbO().count(in: context), in: context) as! [FormalConcept]
    }
    
    public func countFactorization(using conceptsArray: [Bicluster], in context: FormalContext) -> [Bicluster] {
        _ = super.countFactors(in: context)
        var factors: [Bicluster] = []
        var coverage: [CoverageTuple] = conceptsArray.enumerated().map { ($0, $1, $1.coverageSize) }
        var cells = createCells(from: coverage)
        
        while !(coverage.filter({ $0.coverage > 0 }).isEmpty) {
            let maxValue = coverage.max(by: { a, b in a.coverage < b.coverage })!
            factors.append(maxValue.concept)
                        
            for tuple in maxValue.concept.cartesianProduct {
                let index = self.index(of: tuple)
                    
                cells[index]?.removeAll(where: { $0 == maxValue.conceptIndex })
                
                cells[index]?.forEach {
                    coverage[$0] = (coverage[$0].conceptIndex, coverage[$0].concept, coverage[$0].coverage - 1)
                }
                
                cells[index] = nil
            }
            
            coverage[maxValue.conceptIndex] = (maxValue.conceptIndex,
                                               maxValue.concept,
                                               0)

        }
                
        return factors
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

