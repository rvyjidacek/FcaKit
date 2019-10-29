//
//  GreCon2.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/10/2019.
//

import Foundation

public class GreCon2: BMFAlgorithm {
    
    private typealias
    
    public override func countFactors(in matrix: Matrix) -> Set<FormalConcept> {
        let concepts = PFCbO().count(in: FormalContext(values: matrix))
        var coverage: [(conceptIndex: Int, coverage: Int)] = concepts.enumerated().map { ($0, $1.attributes.count * $1.objects.count) }
        coverage.sort(by: { $0.coverage > $1.coverage })
        
        print(concepts)
        print(coverage)
        
        return concepts
    }
    
    fileprivate func createCells(from concepts: Set<FormalConcept>, ofSize size: Int) -> [[Int]?] {
        
    }
}

