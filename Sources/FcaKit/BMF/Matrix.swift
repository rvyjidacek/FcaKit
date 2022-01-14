//
//  Matrix.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 05/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//


public typealias Matrix = [[Int]]

public extension Matrix {
    
    init(rows: Int, cols: Int) {
        self = [[Int]](repeating: [Int](repeating: 0, count: cols), count: rows)
    }
    
    var htmlDescription: String {
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
    
    var fimi: String {
        var fimiDesription = ""
        
        for row in self {
            var columns = row.enumerated()
                             .compactMap({ $0.element == 1 ? $0.offset.description : nil })
                             .joined(separator: " ")
            fimiDesription.append(columns)
            fimiDesription.append("\n")
        }
        return fimiDesription
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
    
    func printCoverage(cover: [CartesianProduct.Tuple]) -> String {
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
