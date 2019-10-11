//
//  FCA.swift
//  FCA
//
//  Created by Roman Vyjídáček on 04.06.18.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import Foundation


public class CbO: FcaAlgorithm {
    
    public override var name: String {
        return "Close by One"
    }
    
    var closureCount: UInt = 0
    
    public override func count(in context: FormalContext, outputFormat format: OutputFormat = .Object) -> Set<FormalConcept> {
        let initialConcept = FormalConcept(objects: context.allObjects,
                                                  attributes: context.up(objects: 0..<context.objectCount))
        return self.count(in: context, concept: initialConcept, attribute: 0)
    }
    
    public func count(in context: FormalContext, concept: FormalConcept, attribute: Attribute)  -> Set<FormalConcept> {
        self.context = context
        self.concepts = []
        self.closureCount = 0
        self.conceptsCount = 0
        self.allAttributes = context.allAttributes
       
        
        x = context.attributeSet()
        y = context.attributeSet()
        c = context.objectSet()
        d = context.attributeSet()
        down = context.objectSet()
        generateFrom(concept: concept, attribute: attribute)
        objectSetStack = Stack<BitSet>()
        attributeSetStack = Stack<BitSet>()
        return concepts
    }
    
    private var allAttributes: BitSet!
    
    private var c: BitSet!
    private var d: BitSet!
    private var x: BitSet!
    private var y: BitSet!
    private var down: BitSet!
    
    func generateFrom(concept: FormalConcept, attribute: Attribute) {
        store(concept: concept)
        if concept.attributes == allAttributes || attribute >= context!.attributeCount {
            return
        }
        
        for j in attribute..<context!.attributeCount {
            if !(concept.attributes.contains(j)) {
                c.setValues(to: concept.objects)
                context!.down(attribute: j, into: down)
                c.intersection(with: down)
                context!.up(objects: c, into: d)
                self.closureCount += 1

                x.addMany(0..<j)
                x.intersection(with: concept.attributes)

                y.addMany(0..<j)
                y.intersection(with: d)
                if x == y {
                    generateFrom(concept: FormalConcept(objects: BitSet(bitset: c),
                                                        attributes: BitSet(bitset: d)),
                                 attribute: j + 1)
                }
            }
        }
    }
}
