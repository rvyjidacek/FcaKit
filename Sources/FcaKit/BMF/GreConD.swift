//
//  GreConD.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 06/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class GreConD: BMFAlgorithm {
    
    
    /*
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
                let concept = FormalConcept(objects: downD, attributes: BitSet(bitset: D))
                F.append(concept)
                //F.insert(concept)
                
                for tuple in concept.cartesianProduct {
                    U.remove(tuple)
                    //coverage.append(tuple)
                }
            }
        }
        
        //print(context.values.printCoverage(cover: coverage))
        
        return F
    }
    */
    
    
    override var context: FormalContext! {
        didSet {
            self.atributes = BitSet(size: self.context.attributeCount)
            self.objects = BitSet(size: self.context.objectCount)
            self.cartesianProduct = CartesianProduct(rows: context.objectCount,
                                                     cols: context.attributeCount)
        }
    }
    
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        self.context = context
        let U = CartesianProduct(context: context)
        var F: [FormalConcept] = []
        var D = context.attributeSet()
        
        let tmpCartesianProduct = CartesianProduct(rows: context.objectCount,
                                                   cols: context.attributeCount)
        
        
        let downD = context.objectSet()
        
        while !(U.isEmpty) {
            D.erase()
            var V = 0
            
            while let j = findAttributeWhichMaximizeCoverage(D, V, U) {
                D.insert(j)
                D = context.downAndUp(attributes: D)

                context.down(attributes: D, into: downD)
                                
                tmpCartesianProduct.values.erase()
                tmpCartesianProduct.insert(a: downD, b: D)
                tmpCartesianProduct.intersection(U)

                V = tmpCartesianProduct.count
            }
            
            let concept = FormalConcept(objects: BitSet(bitset: downD),
                                        attributes: BitSet(bitset: D))
            F.append(concept)
            
            tmpCartesianProduct.values.erase()
            tmpCartesianProduct.insert(a: concept.objects, b: concept.attributes)
            
            for tuple in tmpCartesianProduct {
                U.remove(tuple)
            }
        }
        
        
        
        return F
    }
    
    private func findAttributeWhichMaximizeCoverage(_ D: BitSet, _ V: Int, _ U: CartesianProduct) -> Attribute? {
        var maxValue = 0
        var maxAttribute: Int? = nil
        
        for j in 0..<context.attributeCount { //context.allAttributes {
            if !(D.contains(j)) {
                let dPlusJ = setPlus(of: D, with: j, tuples: U)
                if dPlusJ.count > V && dPlusJ.count > maxValue { //dPlusJ.count > maxValue {
                    maxValue = dPlusJ.count
                    maxAttribute = j
                }
            }
        }
        
        return maxAttribute
    }
    
//    private func setPlus(of attributeSet: BitSet, with attribute: Attribute, tuples: CartesianProduct) -> CartesianProduct {
//        var a = BitSet(bitset: attributeSet)
//        a.insert(attribute)
//        a = context.down(attributes: a)
//
//        let b = context.up(objects: a)
//        return tuples.intersected(CartesianProduct(a: a, b: b))
//    }
    
    private var atributes: BitSet!
    private var objects: BitSet!
    private var cartesianProduct: CartesianProduct!
    
    
    private func setPlus(of attributeSet: BitSet, with attribute: Attribute, tuples: CartesianProduct) -> CartesianProduct {
        atributes.setValues(to: attributeSet)
        atributes.insert(attribute)
    
        context.down(attributes: atributes, into: objects)
        context.up(objects: objects, into: atributes)
        
        cartesianProduct.values.erase()
        cartesianProduct.insert(a: objects, b: atributes)
        cartesianProduct.intersection(tuples)
        return cartesianProduct
    }
}
