//
//  Matrix.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 05/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation


public typealias Matrix = [[Int]]

extension Matrix {
    
    var tuples: Set<Tuple> {
        var tuples: Set<Tuple> = []
        for row in 0..<count {
            for col in 0..<self[row].count {
                if self[row][col] == 1 {
                    tuples.insert(Tuple(a: row, b: col))
                }
            }
        }
        return tuples
    }
    
}
