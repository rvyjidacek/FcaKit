//
//  InClose4.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 18/04/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class InClose4: FcaAlgorithm {
    
    override public var name: String {
        return "In-Close4"
    }
    
    override public func count(in context: FormalContext, outputFormat format: OutputFormat = .Object) -> Set<FormalConcept> {
        self.context = context
        self.concepts = Set<FormalConcept>()
        self.yj = getattributeSet()
        self.cUp = getattributeSet()
        self.c = getObjectSet()
        computeConcepts(from: FormalConcept(objects: context.allObjects, attributes: context.attributeSet()), y: 0, p: context.attributeSet())
        
        if context.down(attributes: context.allAttributes).isEmpty {
            concepts.insert(FormalConcept(objects: context.objectSet(), attributes: context.allAttributes))
        }
        
        return concepts
    }

    private var yj: BitSet!
    private var cUp: BitSet!
    private var c: BitSet!
    
    private func computeConcepts(from concept: FormalConcept, y: Attribute, p: BitSet, level: Int = 0) {
        let objectsQueue = Queue<BitSet>()
        let attributeQueue = Queue<Attribute>()
        let a = BitSet(bitset: concept.objects)
        let b = BitSet(bitset: concept.attributes)
        let p = BitSet(bitset: p)
        //let yj = BitSet(size: context!.attributeCount)
        
        for j in y..<context!.attributeCount {
            if !b.contains(j) && !p.contains(j) {
                //let c = context!.down(attribute: j)
                c.setValues(to: context!.attributes[j])
                c.intersection(with: a)
                
                if !c.isEmpty {
                    if c == a {
                        b.insert(j)
                    } else {
                        yj.addMany(0..<j)
                        yj.intersection(with: b)
                        
                        context?.up(objects: c, upto: j, into: cUp)
                        
                        if yj == cUp { //context!.up(objects: c, upto: j) {
                            objectsQueue.enqueue(getObjectSet(with: c))
                            attributeQueue.enqueue(j)
                        }
                    }
                } else {
                    p.insert(j)
                }
            }
            
        }   
        
        store(concept: FormalConcept(objects: a, attributes: b))
        let q = p
        
        while !objectsQueue.isEmpty {
            let j = attributeQueue.dequeue()!
            let d = BitSet(bitset: b)
            d.insert(j)
            
            computeConcepts(from: FormalConcept(objects: objectsQueue.dequeue()!, attributes: d),
                            y: j + 1,
                            p: q,
                            level: level + 1)
        }
    }
    
    private func print(message: String, count: Int) {
        Swift.print(String(repeating: "   ", count: count), separator: "", terminator: "")
        Swift.print(message)
    }
    
}
