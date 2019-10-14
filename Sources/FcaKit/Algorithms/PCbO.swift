//
//  PCbO.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/01/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

@available(OSX 10.12, *)
public class PCbO: FcaAlgorithm {
    
    public override var name: String {
        return "Parallel Close by One"
    }
    
    private let numberOfThreads: Int = 4
    
    private let stopRecursionLevel: UInt = 2
    
    private var r: Int = -1
    
    let lock = NSLock()
    
    private var conceptQueues: [Queue<FormalConcept>] = []
    private var attributeQueues: [Queue<Attribute>] = []
    
    let dispatchQueue = DispatchQueue(label: "cz.inf.upol.fcakit.pcbo", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    public override func count(in context: FormalContext, outputFormat format: OutputFormat = .Object) -> Set<FormalConcept> {
        self.context = context
        self.concepts = []
//        x = context.attributeSet()
//        y = context.attributeSet()
//        c = context.objectSet()
//        d = context.attributeSet()
//        down = context.objectSet()
        
        let initialConcept = FormalConcept(objects: context.allObjects,
                                           attributes: context.up(objects: context.allObjects))
        conceptQueues = (0..<numberOfThreads).map({ (i) -> Queue<FormalConcept> in
            return Queue<FormalConcept>()
        })
        
        attributeQueues = (0..<numberOfThreads).map({ (i) -> Queue<Attribute> in
            return Queue<Attribute>()
        })
        
        down = (0...numberOfThreads).map { _ in context.objectSet() }
        x = (0...numberOfThreads).map { _ in context.attributeSet() }
        y = (0...numberOfThreads).map { _ in context.attributeSet() }
        d = (0...numberOfThreads).map { _ in context.attributeSet() }
        c = (0...numberOfThreads).map { _ in context.objectSet() }
        
        parallelGenerateFrom(concept: initialConcept, attribute: 0, depthLevel: 0)
        return concepts
    }
    
    //    private var c: BitSet!
    //    private var d: BitSet!
    //    private var x: BitSet!
    //    private var y: BitSet!
    //    private var down: BitSet!
    
    private var down: [BitSet] = []
    private var x: [BitSet] = []
    private var y: [BitSet] = []
    private var d: [BitSet] = []
    private var c: [BitSet] = []
    
    private func parallelGenerateFrom(concept: FormalConcept, attribute: Attribute, depthLevel: UInt) {
        if stopRecursionLevel == depthLevel {
            r = (r + 1) % numberOfThreads
            conceptQueues[r].enqueue(concept)
            attributeQueues[r].enqueue(attribute)
            return
        }
        
        let down = self.down[numberOfThreads]
        let x = self.x[numberOfThreads]
        let y = self.y[numberOfThreads]
        let d = self.d[numberOfThreads]
        let c = self.c[numberOfThreads]
        
        store(concept: concept)
        
        if !((concept.attributes == context?.allAttributes)) {
            for j in attribute..<context!.attributeCount {
                if !concept.attributes.contains(j) {
                    c.setValues(to: concept.objects)
                    context!.down(attribute: j, into: down)
                    c.intersection(with: down)
                    
                    context?.up(objects: c, into: d)
                    x.addMany(0..<j)
                    x.intersection(with: d)
                    
                    y.addMany(0..<j)
                    y.intersection(with: concept.attributes)
                    if x == y {
                        parallelGenerateFrom(concept: FormalConcept(objects: BitSet(bitset: c),
                                                                    attributes: BitSet(bitset: d)),
                                             attribute: j + 1,
                                             depthLevel: depthLevel + 1)
                    }
                }
            }
        }
        
        if depthLevel == 0 {
            DispatchQueue.concurrentPerform(iterations: numberOfThreads) { (id) in
                let conceptsQueue = self.conceptQueues[id]
                let attributesQueue = self.attributeQueues[id]
                for _  in 0..<conceptsQueue.count {
                    self.generateFrom(concept: conceptsQueue.dequeue()!,
                                      attribute: attributesQueue.dequeue()!,
                                      processId: id)
                }
                
            }
        }
    }
    
    
    func generateFrom(concept: FormalConcept, attribute: Attribute, processId: Int) {
        store(concept: concept)
        if concept.attributes == context!.allAttributes || attribute >= context!.attributeCount {
            return
        }
        
        let down = self.down[processId]
        let x = self.x[processId]
        let y = self.y[processId]
        let d = self.d[processId]
        let c = self.c[processId]
        
        for j in attribute..<context!.attributeCount {
            if !(concept.attributes.contains(j)) {
                c.setValues(to: concept.objects)
                context!.down(attribute: j, into: down)
                c.intersection(with: down)
                context!.up(objects: c, into: d)
                
                x.addMany(0..<j)
                x.intersection(with: concept.attributes)
                
                y.addMany(0..<j)
                y.intersection(with: d)
                if x == y {
                    generateFrom(concept: FormalConcept(objects: BitSet(bitset: c),
                                                        attributes: BitSet(bitset: d)),
                                 attribute: j + 1, processId: processId)
                }
            }
        }
    }
    
    override func store(concept: FormalConcept) {
        lock.lock()
        super.store(concept: concept)
        lock.unlock()
    }
    
    private func computeClosure(concept: FormalConcept, attribute: Attribute) -> FormalConcept {
        let objects = BitSet(size: context!.objectCount)
        let attributes = BitSet(bitset: concept.attributes)
        let attributeObjects = context!.down(attribute: attribute)
        
        
        for x in (concept.objects.unioned(attributeObjects)) {
            let setX = BitSet(size: context!.objectCount, values: [x])
            objects.intersection(with: setX)
            attributes.intersection(with: context!.up(objects: setX))
        }
        return FormalConcept(objects: objects, attributes: attributes)
    }
}
