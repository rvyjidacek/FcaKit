//
//  GreCon2.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/10/2019.
//

import Foundation

public class GreCon2: BMFAlgorithm {
    
    public override func countFactors(in matrix: Matrix) -> Set<FormalConcept> {
        let concepts = PFCbO().count(in: FormalContext(values: matrix))
        var coverage = concepts.map { $0.attributes.count * $0.objects.count }
        coverage.sort()
        
        return concepts
    }
    
    fileprivate func createCells(from concepts: Set<FormalConcept>, ofSize size: Int) -> [[Int]?] {
        return []
    }
}

