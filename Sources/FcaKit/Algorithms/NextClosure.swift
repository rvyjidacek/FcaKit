//
//  NextClosure.swift
//  FormalConceptAnalysis
//
//  Created by Roman Vyjídáček on 27/08/2018.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class NextClosure: FcaAlgorithm {
        
    private var diff: BitSet!
    private var zeroToI: BitSet!
    private var x: BitSet!
    private var y: BitSet!
    private var a: BitSet!
    private var aDown: BitSet!
    
    public override var name: String {
        return "Next Closure"
    }
    
    public override func count(in context: FormalContext) -> [FormalConcept] {
        self.context = context
        self.a = context.attributeSet()
        self.aDown = context.objectSet()
        self.diff = context.attributeSet()
        self.zeroToI = context.attributeSet()
        self.x = context.attributeSet()
        self.y = context.attributeSet()
        
        var a = context.up(objects: 0..<context.objectCount)
        
        store(concept: FormalConcept(objects: context.down(attributes: a), attributes: a))
        
        let allAttributes = context.allAttributes
        
        while !(a == allAttributes) {
            a = leastGraterIntent(intent: a)
            store(concept: FormalConcept(objects: context.down(attributes: a),
                                         attributes: a))
        }
        return concepts
    }
    
    private func leastGraterIntent(intent: BitSet) -> BitSet {
        for i in (0..<context!.attributeCount).reversed() {
            let intentPlusI = setPlus(set: intent, i: i)
            if lessThan(left: intent, right: intentPlusI, i: i) {
                return intentPlusI
            }
        }
        return intent
    }
    
    
    
    public func lessThan(left: BitSet, right: BitSet, i: Attribute) -> Bool {
        diff.setValues(to: right)
        diff.difference(left)

        //zeroToI.erase()
        zeroToI.addMany(0..<i)
        
        x.setValues(to: left)
        x.intersection(with: zeroToI)
        
        y.setValues(to: right)
        y.intersection(with: zeroToI)
        
        return diff.contains(i) && x == y
    }
    
    
    public func setPlus(set: BitSet, i: Attribute) -> BitSet {
        //a.erase()
        a.addMany(0..<i)
        a.intersection(with: set)
        a.insert(i)
        
        context?.down(attributes: a, into: aDown)
        return context!.up(objects: aDown)
    }
}
