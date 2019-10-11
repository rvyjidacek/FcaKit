//
//  GreCon.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 05/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

class GreCon: BMFAlgorithm {
    
    public func countBMF(of matrix: Matrix, using fcaAlgorithm: FcaAlgorithm = PFCbO()) -> [FormalConcept] {//Set<FormalConcept> {
        let context = FormalContext(values: matrix)
        var S = fcaAlgorithm.count(in: context)
//        print("\\section*{GreCon}")
//        print("S = \(S.map({$0.latexDescription}))")
        
        var U = tuples(in: matrix)
        
        var F = [FormalConcept]()
    //Set<FormalConcept>()
        //print("F = \(F.map({$0.latexDescription}))")
        let attributeConcepts = self.attributeConcepts(in: context)
        let objectConcepts = self.objectConcepts(in: context)
        let conceptsIntersection = attributeConcepts.intersection(objectConcepts)
        
        //print("Remove attribute and object concepts")
        for concept in S {
            if conceptsIntersection.contains(concept) {
                //print("insert \(concept.latexDescription) to F")
                //print("remove \(concept.latexDescription) from S")
                F.append(concept)//F.insert(concept)
                S.remove(concept)

                for tuple in concept.tuples {
                    U.remove(tuple)
                }

                //print("\n")
            }
        }
        
        //print("S = \(S.description)")
        //print("F = \(F.description)")
        
        while !(U.isEmpty) {
            var covered = Set<Tuple>()
            
            let result = selectMaxCover(of: U, from: S)
//            print("Max cover concept = \(result.concept.latexDescription) cover = \(result.cover)")
            F.append(result.concept)//F.insert(result.concept)
            S.remove(result.concept)
            
            for tuple in result.concept.tuples {
                //U.remove(tuple)
                covered.insert(tuple)
            }
//            
//            printLatexMatrix(tuples: U, covered: covered)
            
            for tuple in result.concept.tuples {
                U.remove(tuple)
                //covered.insert(tuple)
            }
            
            //print("S = \(S.description)")
            //print("F = \(F.description)")
        }
        return F
    }
    
    private func selectMaxCover(of tuples: Set<Tuple>, from concepts: Set<FormalConcept>) -> (concept: FormalConcept, cover: Int) {
        var maxCoverSize = 0
        var maxCoverConcept: FormalConcept?
        
        for concept in concepts {
            let intersectionCount = tuples.intersection(concept.tuples).count
            if intersectionCount > maxCoverSize{
                maxCoverSize = intersectionCount
                maxCoverConcept = concept
            }
        }
        return (maxCoverConcept!, maxCoverSize)
    }
    
    
    
    private func attributeConcepts(in context: FormalContext) -> Set<FormalConcept> {
        var concepts = Set<FormalConcept>()
        for attribute in context.allAttributes {
            let objects = context.down(attribute: attribute)
            let attributes = context.up(objects: objects)
            concepts.insert(FormalConcept(objects: objects, attributes: attributes))
        }
        return concepts
    }
    
    
    private func objectConcepts(in context: FormalContext) -> Set<FormalConcept> {
        var concepts = Set<FormalConcept>()
        for object in context.allObjects {
            let attributes = context.up(object: object)
            let objects = context.down(attributes: attributes)
            concepts.insert(FormalConcept(objects: objects, attributes: attributes))
        }
        return concepts
    }
}

class GreConV2: BMFAlgorithm {
    
    public func countBMF(of matrix: Matrix, using fcaAlgorithm: FcaAlgorithm = PFCbO()) -> [FormalConcept] {//Set<FormalConcept> {
        let context = FormalContext(values: matrix)
        var S = fcaAlgorithm.count(in: context)
        
//        print("\\section*{GreCon with optimization}")
//        print("S = \(S.map({$0.latexDescription}))")
        
        var U = tuples(in: matrix)
        var F = [FormalConcept]()//Set<FormalConcept>()
        let attributeConcepts = self.attributeConcepts(in: context)
        let objectConcepts = self.objectConcepts(in: context)
        let conceptsIntersection = attributeConcepts.intersection(objectConcepts)
        
        for concept in S {
            if conceptsIntersection.contains(concept) {
                F.append(concept)//F.insert(concept)
                S.remove(concept)

                for tuple in concept.tuples {
                    U.remove(tuple)
                }
            }
        }
        
//        printLatexMatrix(tuples: U)
        
        var sortedS = S.sorted(by: {(concept1, concept2) -> Bool in
            return (concept1.attributes.count * concept1.objects.count) > (concept2.attributes.count * concept2.objects.count)
        })
        
        while !(U.isEmpty) {
//            var covered = Set<Tuple>()
            
            let result = selectMaxCover(of: U, from: sortedS)
            
//            print("Max cover concept = \(sortedS[result.index].latexDescription) cover = \(result.cover)")
            F.append(sortedS[result.index])//F.insert(sortedS[result.index])
            
            
            
//            for tuple in sortedS[result.index].tuples {
//                //U.remove(tuple)
//                covered.insert(tuple)
//            }

//            printLatexMatrix(tuples: U, covered: covered)
            
            for tuple in sortedS[result.index].tuples {
                U.remove(tuple)
                //covered.insert(tuple)
            }
            
            sortedS.remove(at: result.index)
            
            
        }
        return F
    }
        
    private func selectMaxCover(of tuples: Set<Tuple>, from concepts: [FormalConcept]) -> (index: Int, cover: Int) {
        var maxCoverSize = tuples.intersection(concepts[0].tuples).count
        var maxCoverConceptIndex: Int = 0
        
        
        for i in 1..<concepts.count {
            if concepts[i].tuples.count < maxCoverSize {
                break
            } else {
                let coverSize = tuples.intersection(concepts[i].tuples).count
                if coverSize > maxCoverSize {
                    maxCoverSize = tuples.intersection(concepts[i].tuples).count
                    maxCoverConceptIndex = i
                }
            }
            
        }
        
        return (maxCoverConceptIndex, maxCoverSize)
    }
    
    
    
    private func attributeConcepts(in context: FormalContext) -> Set<FormalConcept> {
        var concepts = Set<FormalConcept>()
        for attribute in context.allAttributes {
            let objects = context.down(attribute: attribute)
            let attributes = context.up(objects: objects)
            concepts.insert(FormalConcept(objects: objects, attributes: attributes))
        }
        return concepts
    }
    
    
    private func objectConcepts(in context: FormalContext) -> Set<FormalConcept> {
        var concepts = Set<FormalConcept>()
        for object in context.allObjects {
            let attributes = context.up(object: object)
            let objects = context.down(attributes: attributes)
            concepts.insert(FormalConcept(objects: objects, attributes: attributes))
        }
        return concepts
    }
}

func printLatexMatrix(tuples: Set<Tuple>, covered: Set<Tuple> = []) {
//    var matrix = Matrix(repeating: [Int](repeating: 0, count: 8), count: 12)
//
//    for tuple in tuples {
//        matrix[tuple.a][tuple.b] = 1
//    }
//
//    print("$$\\begin{pmatrix}")
//    for row in 0..<matrix.count {
//        print("  ", separator: "", terminator: "")
//        for col in 0..<matrix[row].count {
//            if col == matrix[row].count - 1 {
//                print(!covered.contains(Tuple(a: row, b: col)) ? "\(matrix[row][col]) \\\\" : "\\textbf{\(matrix[row][col])} \\\\", separator: "", terminator: "\n")
//            } else {
//                print(!covered.contains(Tuple(a: row, b: col)) ? "\(matrix[row][col]) & " : "\\textbf{\(matrix[row][col])} & ", separator: "", terminator: "")
//            }
//        }
//    }
//
//    print("\\end{pmatrix}$$")
}
