//
//  GreConD.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 06/06/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//


public class GreConD: BMFAlgorithm {
    
    override var context: FormalContext! {
        didSet {
            self.atributes = BitSet(size: self.context.attributeCount)
            self.objects = BitSet(size: self.context.objectCount)
            self.cartesianProduct = CartesianProduct(rows: context.objectCount,
                                                     cols: context.attributeCount)
        }
    }
    
    public var counts: [FormalConcept: Int] = [:]
    var numberOfTestConcepts = 0
    var iteration = 0
    
    public override func countFactors(in context: FormalContext) -> [FormalConcept] {
        self.context = context
        let uncovered = CartesianProduct(context: context)
        var factors: [FormalConcept] = []
        var d = context.attributeSet()
        
        let tmpCartesianProduct = CartesianProduct(rows: context.objectCount,
                                                   cols: context.attributeCount)
        
        
        let downD = context.objectSet()
        
        while !(uncovered.isEmpty) {
            d.erase()
            var v = 0
            
            while let j = findAttributeWhichMaximizeCoverage(d, v, uncovered) {
                d.insert(j)
                
                d = context.downAndUp(attributes: d)

                context.down(attributes: d, into: downD)
                                
                tmpCartesianProduct.values.erase()
                tmpCartesianProduct.insert(a: downD, b: d)
                tmpCartesianProduct.intersection(uncovered)
                                
                v = tmpCartesianProduct.count
            }
            
            
            let concept = FormalConcept(objects: BitSet(bitset: downD),
                                        attributes: BitSet(bitset: d))
            factors.append(concept)
            
            tmpCartesianProduct.values.erase()
            tmpCartesianProduct.insert(a: concept.objects, b: concept.attributes)
            
            for tuple in tmpCartesianProduct {
                uncovered.remove(tuple)
            }
        }
        
        return factors
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
    
    
    private var atributes: BitSet!
    private var objects: BitSet!
    private var cartesianProduct: CartesianProduct!
    
    public var concepts = Set<FormalConcept>()
    
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
