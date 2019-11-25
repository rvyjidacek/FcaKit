//
//  GreCon.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 05/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class GreCon: BMFAlgorithm {

    var covered: CartesianProduct!
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        self.context = context
        var S = FCbO().count(in: context)
        let U = CartesianProduct(context: context)
        
        self.tuplesIntersection = CartesianProduct(context: context)
        var F = [FormalConcept]()
        let attributeConcepts = self.attributeConcepts(in: context)
        let objectConcepts = self.objectConcepts(in: context)
        let conceptsIntersection = attributeConcepts.intersection(objectConcepts)
        
        for concept in S {
            if conceptsIntersection.contains(concept) {
                F.append(concept)
                S.remove(concept)
                
                for tuple in concept.cartesianProduct {
                    U.remove(tuple)
                }
            }
        }
        
        self.covered = CartesianProduct(rows: context.objectCount, cols: context.attributeCount)
        
        while !(U.isEmpty) {
            covered.values.erase()
            
            let result = selectMaxCover(of: U, from: S)
            F.append(result.concept)
            S.remove(result.concept)
            
            for tuple in result.concept.cartesianProduct {
                covered.insert(tuple)
            }
            
            
            for tuple in result.concept.cartesianProduct {
                U.remove(tuple)
            }

        }
        return F
    }
    
    
    fileprivate var tuplesIntersection: CartesianProduct!
    
    private func selectMaxCover(of tuples: CartesianProduct, from concepts: Set<FormalConcept>) -> (concept: FormalConcept, cover: Int) {
        var maxCoverSize = 0
        var maxCoverConcept: FormalConcept?
        
        for concept in concepts {
            tuplesIntersection.copyValues(tuples)
            tuplesIntersection.intersection(concept.cartesianProduct)
            let intersectionCount = tuplesIntersection.count
            
            if intersectionCount > maxCoverSize {
                maxCoverSize = intersectionCount
                maxCoverConcept = concept
            }
        }
        return (maxCoverConcept!, maxCoverSize)
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

public class GreConV2: BMFAlgorithm {
    
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        var S = PFCbO().count(in: context)
        
        var U = tuples(in: context)
        var F = [FormalConcept]()
        let attributeConcepts = self.attributeConcepts(in: context)
        let objectConcepts = self.objectConcepts(in: context)
        let conceptsIntersection = attributeConcepts.intersection(objectConcepts)
        
        for concept in S {
            if conceptsIntersection.contains(concept) {
                F.append(concept)
                S.remove(concept)
                
                for tuple in concept.tuples {
                    U.remove(tuple)
                }
            }
        }
        
        
        var sortedS = S.sorted(by: {(concept1, concept2) -> Bool in
            return (concept1.attributes.count * concept1.objects.count) > (concept2.attributes.count * concept2.objects.count)
        })
        
        while !(U.isEmpty) {
            
            let result = selectMaxCover(of: U, from: sortedS)
            
            F.append(sortedS[result.index])
            
            for tuple in sortedS[result.index].tuples {
                U.remove(tuple)
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

