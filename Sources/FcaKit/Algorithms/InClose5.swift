//
//  InClose5.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 10/05/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//


public class InClose5: FcaAlgorithm {
    
    override public var name: String {
        return "In-Close5"
    }
    
    public override func count(in context: FormalContext) -> [FormalConcept] {
        self.context = context
        self.concepts = []
        
        self.yj = context.attributeSet()
        self.cUp = context.attributeSet()
        self.c = context.objectSet()
        
        computeConcepts(from: FormalConcept(objects: context.allObjects,
                                            attributes: context.attributeSet()),
                        attribute: 0,
                        p: context.attributeSet(),
                        n: context.attributeSet())
        
        if context.down(attributes: context.allAttributes).isEmpty {
            concepts.append(FormalConcept(objects: context.objectSet(), attributes: context.allAttributes))
        }
        
        return concepts
    }
    
    private var yj: BitSet!
    private var cUp: BitSet!
    private var c: BitSet!
    
    private func computeConcepts(from concept: FormalConcept, attribute y: Attribute, p: BitSet, n: BitSet) {
        let objectsQueue = Queue<BitSet>()
        let attributeQueue = Queue<Attribute>()
        
        let a = BitSet(bitset: concept.objects)
        let b = BitSet(bitset: concept.attributes)
        
        let p = BitSet(bitset: p)
        let n = BitSet(bitset: n)
        
        for j in y..<context!.attributeCount {
            if !b.contains(j) && !p.contains(j) && !n.contains(j) {
                c.setValues(to: context!.down(attribute: j))
                c.intersection(with: a)
                
                if !c.isEmpty {
                    context!.up(objects: c, upto: j, into: cUp)
                    yj.addMany(0..<j)
                    yj.intersection(with: b)
                    
                    if c == a {
                        b.insert(j)
                    } else if yj == cUp {
                        objectsQueue.enqueue(BitSet(bitset: c))
                        attributeQueue.enqueue(j)
                    } else {
                        cUp.difference(b)
                        
                        if cUp.element()! < y {
                            n.insert(j)
                        }
                    }
                } else {
                    p.insert(j)
                }
            }
        }
        store(concept: concept)
        
        while !objectsQueue.isEmpty {
            let j = attributeQueue.dequeue()!
            let d = BitSet(bitset: b)
            d.insert(j)
            
            computeConcepts(from: FormalConcept(objects: objectsQueue.dequeue()!, attributes: d),
                            attribute: j + 1,
                            p: p,
                            n: n)
        }
    }
}
