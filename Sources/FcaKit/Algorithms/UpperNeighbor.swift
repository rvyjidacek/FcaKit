//
//  UpperNeighbor.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 12/09/2018.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//


public class UpperNeighbor: FcaAlgorithm {
    
    public override var name: String {
        return "Upper Neighbor"
    }
    
    private var allObjects: BitSet!
    private var tmpBitset: BitSet!
    private var min: BitSet!
    
    
    
    
    public override func count(in context: FormalContext) -> [FormalConcept] {
        _ = super.count(in: context)
        /*self.allObjects = context.allObjects
        self.tmpBitset = context.objectSet()
        self.b = context.objectSet()
        self.min = context.objectSet()
        self.bUp = context.attributeSet()
        self.a = context.objectSet()
        
        let initialConcept = countInitialConcept()
        concepts.insert(initialConcept)
        
        let upperNeighbors = countUpperNeighbors(initialConcept: countInitialConcept())
        concepts = concepts.union(upperNeighbors)
        let queue: Queue<FormalConcept> = Queue<FormalConcept>(upperNeighbors)
        
        while !queue.isEmpty {
            let upperConcepts = countUpperNeighbors(initialConcept: queue.dequeue()!)
            for concept in upperConcepts {
                if !concepts.contains(concept) {
                    queue.enqueue(concept)
                    concepts.insert(concept)
                }
            }
        }*/
        
        return concepts
    }
    
    private var a: BitSet!
    private var b: BitSet!
    private var bUp: BitSet!
    
    private func countUpperNeighbors(initialConcept: FormalConcept) -> Set<FormalConcept> {
        min.setValues(to: allObjects)
        min.difference(initialConcept.objects)
        
        var neighbors: Set<FormalConcept> = []
        
        for object in min {
            var b = BitSet(bitset: initialConcept.objects)
            b.setValues(to: initialConcept.objects)
            b.insert(object)
            
            context?.up(objects: b, into: bUp)
            
            b = context!.up(objects: b)
            
            let a = context!.down(attributes: b)
            //context?.down(attributes: bUp, into: a)
            
            tmpBitset.setValues(to: a)
            tmpBitset.difference(allObjects)
            tmpBitset.remove(object)
            tmpBitset.intersection(with: min)
            
            if tmpBitset.isEmpty {
                neighbors.insert(FormalConcept(objects: BitSet(bitset: a),
                                               attributes: BitSet(bitset: b)))
            } else {
                min.remove(object)
            }
        }
        
        return neighbors
    }
    
    private func countInitialConcept() -> FormalConcept {
        return FormalConcept(objects: context!.upAndDown(objects: context!.objectSet()),
                             attributes: context!.up(objects: context!.objectSet()))
    }
}

