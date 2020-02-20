//
//  ELL.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 29/01/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//


public class ELL: FcaAlgorithm {
    
    public override var name: String {
        return "ELL"
    }
    
//    public override func count(in context: FormalContext) -> [FormalConcept] {
//        _ = super.count(in: context)
//        z = context.attributeSet()
//        allObjects = context.allObjects
//        a = context.objectSet()
//        z0Tmp = context.attributeSet()
//        r = context.objectSet()
//
//        ell(x0: context.objectSet(), k:  context.allObjects)
//        store(concept: FormalConcept(objects: context.upAndDown(objects: BitSet(size: context.attributeCount)), attributes: context.allAttributes))
//
//        return concepts
//    }
    
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
            
            let aValues = allObjects.filter({
                closureCount += 1
                return z.isSubset(of: context!.up(object: $0))
            })
            
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
                closureCount += 1
                return z0Tmp.isSubset(of: i0Up)
            })
            
            //let r = BitSet(size: context!.objectCount, values: rValues)
            r.erase()
            r.addMany(rValues)
            ell(x0: x0, k: k.differenced(r))
        }
    }
    
    public var L: [BitSet] = []
    public var Beta = 0
    
    
    public override func count(in context: FormalContext) -> [FormalConcept] {
        _ = super.count(in: context)
        self.context = context
        L.append(context.down(attributes: context.allAttributes))
        Beta = context.objectCount

        return concepts
    }
    
    public func ff(A: BitSet, J: BitSet) {
        if context!.down(attributes: A).count < Beta || J.isEmpty {
            return
        }
        
        let j = J.element()!
        let B = atr(A: A, j: j)
        let C = rej(A: A, j: j)
        
        let ADown = context!.down(attributes: A)
        let BDown = context!.down(attributes: B)
        
        if B.isSubset(of: J) && ADown.intersected(BDown).count >= Beta {
            L.append(A.unioned(B))
            ff(A: A.unioned(B), J: J.differenced(B))
        }
        ff(A: A, J: J.differenced(C))
        
    }
    
    private func t(A: BitSet, a: Attribute) -> BitSet {
        let ADown = context!.down(attributes: A)
        let aDown = context!.down(attribute: a)
        return ADown.intersected(aDown)
    }
    
    private func atr(A: BitSet, j: Attribute) -> BitSet {
        let atributes = context!.allAttributes
        atributes.difference(A)
        let values = atributes.compactMap { (a) -> Attribute? in
            return t(A: A, a: j).isSubset(of: t(A: A, a: a)) ? a : nil
        }
        
        let result = context!.attributeSet()
        result.addMany(values)
        return result
    }
    
    private func rej(A: BitSet, j: Attribute) -> BitSet {
        let atributes = context!.allAttributes
        atributes.difference(A)
        let values = atributes.compactMap { (a) -> Attribute? in
            return t(A: A, a: a).isSubset(of: t(A: A, a: j)) ? a : nil
        }
        
        let result = context!.attributeSet()
        result.addMany(values)
        return result
    }
}
