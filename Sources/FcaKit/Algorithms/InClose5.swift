//
//  InClose5.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 10/05/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

class InClose5: FcaAlgorithm {
    
    override var name: String {
        return "In-Close5"
    }
    
    override func count(in context: FormalContext, outputFormat format: OutputFormat = .Object) -> Set<FormalConcept> {
        self.context = context
        self.concepts = Set<FormalConcept>()
        
        computeConcepts(from: FormalConcept(objects: context.allObjects,
                                            attributes: context.attributeSet()),
                        attribute: 0,
                        p: context.attributeSet(),
                        n: context.attributeSet())
        return concepts
    }
    
    private func computeConcepts(from concept: FormalConcept, attribute y: Attribute, p: BitSet, n: BitSet) {
        let objectsQueue = Queue<BitSet>()
        let attributeQueue = Queue<Attribute>()
        let p = BitSet(bitset: p)
        let n = BitSet(bitset: n)
        
        for j in y..<context!.attributeCount {
            if !concept.attributes.contains(j) && !p.contains(j) && !n.contains(j) {
                let c = context!.down(attribute: j)
                c.intersection(with: concept.objects)
                
                if !c.isEmpty {
                    if c == concept.objects {
                        concept.attributes.insert(j)
                    } else if concept.attributes.intersected(context!.atributeSet(withValues: 0..<j)) == context!.up(objects: c, upto: j) {
                        objectsQueue.enqueue(c)
                        attributeQueue.enqueue(j)
                    } else if context!.up(objects: c, upto: j).element()! < y {
                        n.insert(j)
                    }
                } else {
                    p.insert(j)
                }
            }
        }
        store(concept: concept)
        
        while !objectsQueue.isEmpty {
            let j = attributeQueue.dequeue()!
            let d = BitSet(bitset: concept.attributes)
            d.insert(j)
            
            computeConcepts(from: FormalConcept(objects: objectsQueue.dequeue()!, attributes: d),
                            attribute: j + 1,
                            p: p,
                            n: n)
        }
    }
}
