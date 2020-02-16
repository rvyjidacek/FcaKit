//
//  Matrix.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 05/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//


public typealias Matrix = [[Int]]

extension Matrix {
    
    public var htmlDescription: String {
        var htmlString = "<table>"
        
        for row in 0..<count {
            htmlString.append("<tr>")
            for col in 0..<self[row].count {
                htmlString.append("<td>\(self[row][col])</td>")
            }
            htmlString.append("</tr>")
        }
        
        htmlString.append("</table>")
        return htmlString
    }
    
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
    
    var size: (rows: Int, columns: Int) { (self.count, self.first?.count ?? 0) }
    
    public func printCoverage(cover: [CartesianProduct.Tuple]) -> String {
        var htmlString = "<table>"
    
        for row in 0..<count {
            htmlString.append("<tr>")
            for col in 0..<self[row].count {
                if self[row][col] == 1 && cover.first(where: { $0.row == row && $0.col == col }) != nil {
                    htmlString.append("<td bgcolor=\"#ffce0f\"><b>\(self[row][col])</b></td>")
                } else {
                    if self[row][col] == 1 {
                        htmlString.append("<td bgcolor=\"#D3212D\">\(self[row][col])</td>")
                    } else {
                        htmlString.append("<td>\(self[row][col])</td>")
                    }
                }
                
            }
            htmlString.append("</tr>")
        }
        
        htmlString.append("</table>")
        return htmlString
    }
}
