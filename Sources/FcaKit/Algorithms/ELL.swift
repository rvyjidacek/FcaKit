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
        //Beta = context.objectCount
        
        allAttributes = context.allAttributes
        
        allArrowDown = (0..<context.attributeCount).map { context.down(attribute: $0) }
        
        ADown = context.objectSet()
        BDown = context.objectSet()
        
        aDown1 = context.objectSet()
        ADown1 = context.objectSet()
        
        aDown2 = context.objectSet()
        ADown2 = context.objectSet()
        
        intersection = context.objectSet()
        
        ff(A: context.attributeSet(), J: context.allAttributes)
        print(L.count)
        return concepts
    }
    
    private var intersection: BitSet!
    private var B: BitSet!
    private var ADown: BitSet!
    private var BDown: BitSet!
    
    public func ff(A: BitSet, J: BitSet) {
        context!.down(attributes: A, into: ADown)
        if ADown.count < Beta || J.isEmpty {
            return
        }
        
        //let j = J.element()! // slower than randomElement
        let j = J.randomElement()!
        
        let atrAndRej = countAtrAndRejSets(A: A, j: j)
        
        let B = atrAndRej.atr
        let C = atrAndRej.rej

        //context!.down(attributes: A, into: ADown)
        //context!.down(attributes: B, into: BDown)
                
        if B.isSubset(of: J) && ADown.intersectionCount(BDown) >= Beta {
            L.append(A.unioned(B))
            ff(A: A.unioned(B), J: J.differenced(B))
        }
        
        J.difference(C)
        ff(A: A, J: J)
        
    }
    
    private var allAttributes: BitSet!

    private var allArrowDown: [BitSet] = []
    
    private var aDown1: BitSet!
    private var aDown2: BitSet!
    
    private var ADown1: BitSet!
    private var ADown2: BitSet!
    
    private func countAtrAndRejSets(A: BitSet, j: Attribute) -> (atr: BitSet, rej: BitSet) {
        let atr = context!.attributeSet()
        let rej = context!.attributeSet()
        
        for a in 0..<context!.attributeCount {
            if allAttributes.contains(a) && !(A.contains(a)) {
                context!.down(attributes: A, into: ADown1)
                context!.down(attribute: j, into: aDown1)
                ADown1.intersection(with: aDown1)
                
                context!.down(attributes: A, into: ADown2)
                context!.down(attribute: a, into: aDown2)
                ADown2.intersection(with: aDown2)
                
                if ADown1.isSubset(of: ADown2) {
                    atr.insert(a)
                }
                
                if ADown2.isSubset(of: aDown1) {
                    rej.insert(a)
                }
            }
        }
        return (atr, rej)
    }
    
//    private func atr(A: BitSet, j: Attribute) -> BitSet {
//        allAttributes.setAll()
//        allAttributes.difference(A)
//        let values = allAttributes.compactMap { (a) -> Attribute? in
//
//            context!.down(attributes: A, into: ADown1)
//            context!.down(attribute: j, into: aDown1)
//            aDown1.intersection(with: ADown1)
//
//            context!.down(attributes: A, into: ADown2)
//            context!.down(attribute: a, into: aDown2)
//            aDown2.intersection(with: ADown2)
//
//            return aDown1.isSubset(of: aDown2) ? a : nil
//        }
//
//        let result = context!.attributeSet()
//        result.addMany(values)
//        return result
//    }
//
//    private func rej(A: BitSet, j: Attribute) -> BitSet {
//        allAttributes.setAll()
//        allAttributes.difference(A)
//        let values = allAttributes.compactMap { (a) -> Attribute? in
//
//            context!.down(attributes: A, into: ADown1)
//            context!.down(attribute: a, into: aDown1)
//            aDown1.intersection(with: ADown1)
//
//            context!.down(attributes: A, into: ADown2)
//            context!.down(attribute: j, into: aDown2)
//            aDown2.intersection(with: ADown2)
//
//            return aDown1.isSubset(of: aDown2) ? a : nil
//        }
//
//        let result = context!.attributeSet()
//        result.addMany(values)
//        return result
//    }
}
