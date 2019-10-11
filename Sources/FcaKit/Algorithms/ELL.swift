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
    
    public override func count(in context: FormalContext, outputFormat format: OutputFormat = .Object) -> Set<FormalConcept> {
        self.context = context
        
        ell(x0: context.objectSet(), k:  context.allObjects)
        store(concept: FormalConcept(objects: context.upAndDown(objects: BitSet(size: context.attributeCount)), attributes: context.allAttributes))
        
        return concepts
    }
    
    private func ell(x0: BitSet, k: BitSet) {
        let z0 = context!.up(objects: x0)
        
        if !k.isEmpty {
            let i0 = k.element()!
            let i0Up = context!.up(object: i0)
            let z = z0.intersected(i0Up)
            let aValues = (context!.allObjects.differenced(x0)).filter({ z.isSubset(of: context!.up(object: $0)) })
            let a = BitSet(size: context!.objectCount, values: aValues)
            if a.isSubset(of: k) {
                let v = x0.unioned(a)
                let concept = FormalConcept(objects: v,attributes: z)
                store(concept: concept)
                ell(x0: v, k: k.differenced(a))
            }
            
            let rValues = k.filter({ z0.intersected(context!.up(object: $0)).isSubset(of: i0Up) })
            let r = BitSet(size: context!.objectCount, values: rValues)
            ell(x0: x0, k: k.differenced(r))
        }
    }
    
    private func computeA(z: BitSet, x0: BitSet, k: BitSet) -> BitSet {
        let result = BitSet(size: context!.attributeCount)
        for object in context!.allObjects.differenced(x0) {
            let attributes = context!.up(object: object)
            if z.isSubset(of: attributes) {
                result.insert(object)
            }
        }
        return result
    }
    
    private func computeR(z0: BitSet, i0: BitSet, k: BitSet) -> BitSet {
        let result = BitSet(size: context!.attributeCount)
        for i in k {
            let attributes = context!.up(object: i)
            attributes.intersection(with: z0)
            if attributes.isSubset(of: context!.up(objects: i0)) {
                result.insert(i)
            }
        }
        return result
    }
    
}
