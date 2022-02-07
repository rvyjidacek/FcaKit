//
//  FCA.swift
//  FCA
//
//  Created by Roman Vyjídáček on 04.06.18.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//



public class CbO: FcaAlgorithm {
    
    public override var name: String {
        return "Close by One"
    }
    
    public override func count(in context: FormalContext) -> [FormalConcept] {
        _ = super.count(in: context)
        let initialConcept = FormalConcept(objects: context.allObjects,
                                                  attributes: context.up(objects: 0..<context.objectCount))
        return self.count(in: context, concept: initialConcept, attribute: 0)
    }
    
    public func count(in context: FormalContext, concept: FormalConcept, attribute: Attribute)  -> [FormalConcept] {
        self.allAttributes = context.allAttributes
       
        
        x = context.attributeSet()
        y = context.attributeSet()
        c = context.objectSet()
        d = context.attributeSet()
        down = context.objectSet()
        generateFrom(concept: concept, attribute: attribute)
        return concepts
    }
    
    private var allAttributes: BitSet!
    
    private var c: BitSet!
    private var d: BitSet!
    private var x: BitSet!
    private var y: BitSet!
    private var down: BitSet!
    
    
    public var ups: [String: Int] = [:]
    
    public var downs: [String: Int] = [:]
    
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
                
                if let count = downs["{\(j)}"] {
                    downs["{\(j)}"] = count + 1
                } else {
                    downs["{\(j)}"] = 1
                }
                
                if let count = ups[c.description] {
                    ups[c.description] = count + 1
                } else {
                    ups[c.description] = 1
                }
                
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
