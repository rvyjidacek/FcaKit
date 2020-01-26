//
//  InClose2.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 01/04/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class InClose2: FcaAlgorithm {
    
    public override var name: String {
        return "In-Close2"
    }
    
    public override func count(in context: FormalContext) -> [FormalConcept] {
        _ = super.count(in: context)
        cUp = context.attributeSet()
        yj = context.attributeSet()
        c = context.objectSet()
        computeConcepts(from: FormalConcept(objects: context.allObjects, attributes: context.attributeSet()), y: 0)
        
        return concepts
    }
    
    private var cUp: BitSet!
    private var yj: BitSet!
    private var c: BitSet!

    private func computeConcepts(from concept: FormalConcept, y: Attribute) {
        let objectsQueue = Queue<BitSet>()
        let attributeQueue = Queue<Attribute>()
        let b = BitSet(bitset: concept.attributes)
        
        for j in y..<context!.attributeCount {
            if !concept.attributes.contains(j) {
                c.setValues(to: context!.attributes[j])
                c.intersection(with: concept.objects)
                
                if c == concept.objects {
                    b.insert(j)
                } else {
                    yj.addMany(0..<j)
                    yj.intersection(with: b)
                    
                    context!.up(objects: c, upto: j, into: cUp)
                    
                    if yj == cUp {
                        objectsQueue.enqueue(BitSet(bitset: c))
                        attributeQueue.enqueue(j)
                    }
                }
            }
        }
        
        store(concept: FormalConcept(objects: BitSet(bitset: concept.objects), attributes: b))
        
        while !objectsQueue.isEmpty {
            let j = attributeQueue.dequeue()!
            let d = BitSet(bitset: b)
            d.insert(j)
            
            computeConcepts(from: FormalConcept(objects: objectsQueue.dequeue()!,
                                                attributes: d), y: j + 1)
        }
    }
}

