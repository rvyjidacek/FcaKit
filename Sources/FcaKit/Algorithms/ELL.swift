//
//  ELL.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 29/01/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class ELL: FcaAlgorithm {
    
    public override var name: String {
        return "ELL"
    }
    
    public override func count(in context: FormalContext) -> [FormalConcept] {
        _ = super.count(in: context)
        z = context.attributeSet()
        allObjects = context.allObjects
        a = context.objectSet()
        z0Tmp = context.attributeSet()
        r = context.objectSet()
        
        ell(x0: context.objectSet(), k:  context.allObjects)
        store(concept: FormalConcept(objects: context.upAndDown(objects: BitSet(size: context.attributeCount)), attributes: context.allAttributes))
        
        return concepts
    }
    
    private var z: BitSet!
    private var allObjects: BitSet!
    private var a: BitSet!
    private var z0Tmp: BitSet!
    private var r: BitSet!
    
    private func ell(x0: BitSet, k: BitSet) {
        let z0 = context!.up(objects: x0)
        
        if !k.isEmpty {
            let i0 = k.element()!
            let i0Up = context!.up(object: i0)
            
            //let z = z0.intersected(i0Up)
            z.setValues(to: z0)
            z.intersection(with: i0Up)
            
            // context!.allObjects.differenced(x0)
            allObjects.addMany(0..<context!.objectCount)
            allObjects.difference(x0)
            
            let aValues = allObjects.filter({ z.isSubset(of: context!.up(object: $0)) })
            
            //let a = BitSet(size: context!.objectCount, values: aValues)
            a.erase()
            a.addMany(aValues)
            
            if a.isSubset(of: k) {
                let v = x0.unioned(a)
                
                self.conceptsCount += 1
                if FcaAlgorithm.saveConcepts {
                    let concept = FormalConcept(objects: BitSet(bitset: v),
                                                attributes: BitSet(bitset: z))
                    concepts.append(concept)
                }
                
                ell(x0: v, k: k.differenced(a))
            }
            
            let rValues = k.filter({
                // z0.intersected(context!.up(object: $0)).isSubset(of: i0Up)
                z0Tmp.setValues(to: z0)
                z0Tmp.intersection(with: context!.up(object: $0))
                return z0Tmp.isSubset(of: i0Up)
            })
            
            //let r = BitSet(size: context!.objectCount, values: rValues)
            r.erase()
            r.addMany(rValues)
            ell(x0: x0, k: k.differenced(r))
        }
    }
}
