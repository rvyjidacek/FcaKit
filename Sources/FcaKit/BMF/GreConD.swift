//
//  GreConD.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 06/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class GreConD: BMFAlgorithm {
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        self.context = context
        self.atributes = BitSet(size: self.context.attributeCount)
        self.objects = BitSet(size: self.context.objectCount)
        
        let U = CartesianProduct(context: context)
        var F: [FormalConcept] = []
        var D = context.attributeSet()
        
        //var coverage: [CartesianProduct.Tuple] = []
        
        while !(U.isEmpty) {
            D.erase()
            var V = 0
            
            let tuples = (0..<context.attributeCount).compactMap { (attribute) -> (attribute: Int, tuples: CartesianProduct)? in
                if D.contains(attribute) { return nil }
                let setPlus = setPlus2(of: D, with: attribute, tuples: U)
                
                return setPlus.count <= V ? nil : (attribute, setPlus)
            }
            
            if let max = tuples.max(by: { a, b in a.tuples.count < b.tuples.count }) {
                D.insert(max.attribute)
                
                D = context.downAndUp(attributes: D)
                //let downD = context.down(attributes: D)
                //context.up(objects: downD, into: D)
                
        
                let downD = context.down(attributes: D)
                //context.down(attributes: D, into: downD)
                
                let tuples = CartesianProduct(a: D, b: downD)
                tuples.intersection(U)
                
                
                //V = tuples.count
                V = downD.cartesianProduct(with: D).intersected(U).count//intersectioned(U).count
                let concept = FormalConcept(objects: downD, attributes: D)
                F.append(concept)
                //F.insert(concept)
                
                for tuple in concept.cartesianProduct {
                    U.remove(tuple)
                    //coverage.append(tuple)
                }
            }
        }
        return F
    }
    
    private func setPlus(of attributeSet: BitSet, with attribute: Attribute, tuples: CartesianProduct) -> CartesianProduct {
        var a = BitSet(bitset: attributeSet)
        a.insert(attribute)
        a = context.down(attributes: a)
            
        let b = context.up(objects: a)
        return tuples.intersected(CartesianProduct(a: a, b: b))
    }
    
    private var atributes: BitSet!
    private var objects: BitSet!
    
    private func setPlus2(of attributeSet: BitSet, with attribute: Attribute, tuples: CartesianProduct) -> CartesianProduct {
        atributes.setValues(to: attributeSet)
        atributes.insert(attribute)
    
        context.down(attributes: atributes, into: objects)
        context.up(objects: objects, into: atributes)
        
        let cartesianProduct = CartesianProduct(a: objects, b: atributes)
        cartesianProduct.intersection(tuples)
        return cartesianProduct
    }
    
    /*
    private func setPlus(of attributeSet: BitSet, with attribute: Attribute, tuples: Set<Tuple>, context: FormalContext) -> Set<Tuple> {
        var a = BitSet(bitset: attributeSet)
        a.insert(attribute)
        a = context.down(attributes: a)
            
        let b = context.up(objects: a)
        
        let concept = FormalConcept(objects: a, attributes: b)
        return tuples.intersection(concept.tuples)
    }
     */
}
