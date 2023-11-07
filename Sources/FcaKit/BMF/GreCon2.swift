//
//  GreCon2.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/10/2019.
//

public final class GreCon2: BMFAlgorithm {
    
    fileprivate typealias CoverageTuple<T: Bicluster> = (conceptIndex: Int, concept: T, coverage: Int)
    
    fileprivate var zerosCartesianProduct: CartesianProduct!
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        return countFactorization(using: FCbO().count(in: context), in: context)
    }
    
    public func countFactorization<T: Bicluster>(using conceptsArray: [T], in context: FormalContext) -> [T] {
        _ = super.countFactors(in: context)
        
        zerosCartesianProduct = CartesianProduct(cartesianProduct: context.cartesianProduct)
        zerosCartesianProduct.values.setAll()
        zerosCartesianProduct.difference(context.cartesianProduct)
        
        var factors: [T] = []
        var coverage: [CoverageTuple<T>] = conceptsArray.enumerated().map { ($0, $1, $1.coverageSize) }
        var cells = createCells(from: coverage, context: context)
        
        // cost = (#1 - #0) 
        // TODO: Do stredy matice A a B pro vsechny datasety OA-Biclusters + Factors
        // Pridat do slozek README.md aby bylo jasne co je ve slozkach za vysledky.
        // pronajem macu limit do 50 000.
        // Poslat grafy pro ruzne weight #1 - pocet prekrytych 0 / celkovy pocet jednicek, pro hustotu 0.95 +-
        
        while !(coverage.filter({ $0.coverage > 0 }).isEmpty) {
            let maxValue = coverage.max(by: { a, b in
                (a.coverage - coveredZeros(bicluster: a.concept, in: context)) < (b.coverage - coveredZeros(bicluster: b.concept, in: context))
            })!
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
    
    fileprivate func coveredZeros(bicluster: Bicluster, in context: FormalContext) -> Int {
        let tuples = bicluster.fullCartesianProduct
        var coveredZeros = 0
        
        for tuple in bicluster.fullCartesianProduct {
            if zerosCartesianProduct.contains(tuple) {
                coveredZeros += 1
                zerosCartesianProduct.remove(tuple)
            }
        }
        
        return coveredZeros
    }
    
    fileprivate func printCells(cells: [[Int]?]) {
        for i in 0..<cells.count {
            if !(cells[i]!.isEmpty) {
                print("\(i). \(tuple(for: i)) -> \(cells[i] ?? [])")
            }
        }
    }
    
    fileprivate func createCells<T>(from tuples: [CoverageTuple<T>], context: FormalContext) -> [[Int]?] {
        var cells = [[Int]?](repeating: [], count: context.objectCount * context.attributeCount)
        
        for coverageTuple in tuples {
            coverageTuple.concept.context = context
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

