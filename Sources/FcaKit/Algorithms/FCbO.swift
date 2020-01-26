//
//  fCbO.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 23/10/2018.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import Foundation


public class FCbO: FcaAlgorithm {
        
    public override var name: String {
        return "Fast Close by One"
    }
    
    public func count(in context: FormalContext, concept: FormalConcept, attribute: Attribute, failedAttributes: UpdatableSet) -> [FormalConcept] {
        self.context = context
        
        yj = context.attributeSet()
        k = context.attributeSet()
        l = context.attributeSet()
        x = context.attributeSet()
        y = context.attributeSet()
        b = context.attributeSet()
        c = context.objectSet()

        fastGenerateFrom(concept: concept,
                         attribute: 0,
                         attributeSets: failedAttributes)
        return concepts
    }
    
    public override func count(in context: FormalContext) -> [FormalConcept] {
        _ = super.count(in: context)
        let initialConcept = FormalConcept(objects: context.allObjects,
                                           attributes: context.up(objects: 0..<context.objectCount))
        return count(in: context, concept: initialConcept, attribute: 0, failedAttributes: UpdatableSet(size: context.attributeCount))
    }
    
    private var yj: BitSet!
    private var k: BitSet!
    private var l: BitSet!
    private var x: BitSet!
    private var y: BitSet!
    private var b: BitSet!
    private var c: BitSet!
    
    func fastGenerateFrom(concept: FormalConcept, attribute: Attribute, attributeSets: UpdatableSet) {
        store(concept: concept)
        
        if concept.attributes == context!.allAttributes || attribute >= context!.attributeCount {
            return
        }
        
        let conceptQueue = Queue<FormalConcept>()
        let attributeQueue = Queue<Attribute>()
        var setMy = attributeSets
        
        for j in attribute..<context!.attributeCount {
            yj.addMany(0..<j)
            b.setValues(to: concept.attributes)
            
            x.setValues(to: attributeSets.get(index: j))
            x.intersection(with: yj)
            
            y.setValues(to: b)
            y.intersection(with: yj)
            
            
            if !b.contains(j) && x.isSubset(of: y) {
                c.setValues(to: context!.attributes[j])
                c.intersection(with: concept.objects)
                
                let d = context!.attributeSet()
                context?.up(objects: c, into: d)
                
                
                k.setValues(to: b)
                k.intersection(with: yj)
                
                l.setValues(to: d)
                l.intersection(with: yj)
                
                if  k == l {
                    conceptQueue.enqueue(FormalConcept(objects: BitSet(bitset: c), attributes: d))
                    attributeQueue.enqueue(j + 1)
                } else {
                    setMy.set(index: j, set: d)
                }
            
            }
        }
        
        while !conceptQueue.isEmpty {
            fastGenerateFrom(concept: conceptQueue.dequeue()!, attribute: attributeQueue.dequeue()!, attributeSets: setMy)
        }
    }
}
