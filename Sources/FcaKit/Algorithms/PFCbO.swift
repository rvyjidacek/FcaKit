//
//  PFCbO.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 31/01/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation


@available(OSX 10.12, *)
public class PFCbO: FcaAlgorithm {

    public override var name: String {
        return "Parallel Fast Close by One"
    }
    
    public var numberOfThreads: Int = 4
    
    public var stopRecursionLevel: UInt = 2
    
    private var r: Int = -1
    
    let mutex = NSLock()
    
    private var conceptQueues: [Queue<FormalConcept>] = []
    private var attributeQueues: [Queue<Attribute>] = []
    private var failedAttributes: [Queue<UpdatableSet>] = []
    
    private var yj: [BitSet] = []
    private var k: [BitSet] = []
    private var l: [BitSet] = []
    private var x: [BitSet] = []
    private var y: [BitSet] = []
    private var b: [BitSet] = []
    private var c: [BitSet] = []
    
    public override func count(in context: FormalContext, outputFormat format: OutputFormat = .Object) -> Set<FormalConcept> {
        self.context = context
        self.concepts = []
        self.r = -1
        let initialConcept = FormalConcept(objects: context.allObjects,
                                           attributes: context.up(objects: context.allObjects))
        
        conceptQueues = (0..<numberOfThreads).map({ (i) -> Queue<FormalConcept> in
            return Queue<FormalConcept>()
        })
        
        attributeQueues = (0..<numberOfThreads).map({ (i) -> Queue<Attribute> in
            return Queue<Attribute>()
        })
        
        failedAttributes = (0..<numberOfThreads).map({ (i) -> Queue<UpdatableSet> in
            return Queue<UpdatableSet>()
        })
        
        yj = (0...numberOfThreads).map { _ in context.attributeSet() }
        k = (0...numberOfThreads).map { _ in context.attributeSet() }
        l = (0...numberOfThreads).map { _ in context.attributeSet() }
        x = (0...numberOfThreads).map { _ in context.attributeSet() }
        y = (0...numberOfThreads).map { _ in context.attributeSet() }
        b = (0...numberOfThreads).map { _ in context.attributeSet() }
        c = (0...numberOfThreads).map { _ in context.objectSet() }
        
        parallelGenerateFrom(concept: initialConcept,
                             attribute: 0,
                             attributeSets: UpdatableSet(size: context.attributeCount),
                             depthLevel: 0)
        return concepts
    }
    
    override func store(concept: FormalConcept) {
        mutex.lock()
        super.store(concept: concept)
        mutex.unlock()
    }
    
    private func parallelGenerateFrom(concept: FormalConcept, attribute: Attribute, attributeSets: UpdatableSet, depthLevel: UInt) {
        if stopRecursionLevel == depthLevel {
            r = (r + 1) % numberOfThreads
            conceptQueues[r].enqueue(concept)
            attributeQueues[r].enqueue(attribute)
            failedAttributes[r].enqueue(attributeSets)
            return
        }
        
        store(concept: concept)
        
        let conceptQueue = Queue<FormalConcept>()
        let attributeQueue = Queue<Attribute>()
        var setMy = attributeSets
        
        let yj = self.yj[numberOfThreads]
        let k = self.k[numberOfThreads]
        let l = self.l[numberOfThreads]
        let x = self.x[numberOfThreads]
        let y = self.y[numberOfThreads]
        let b = self.b[numberOfThreads]
        let c = self.c[numberOfThreads]
        
        if !((concept.attributes == context?.allAttributes) || (attribute >= context!.attributeCount)) {
            for j in attribute..<context!.attributeCount {
                setMy.set(index: j, set: BitSet(bitset: attributeSets.get(index: j)))
                //let yj = BitSet(size: context!.attributeCount, values: 0..<j)
                yj.addMany(0..<j)
                //let b = concept.attributes
                b.setValues(to: concept.attributes)
                
                x.setValues(to: attributeSets.get(index: j))
                x.intersection(with: yj)
                
                y.setValues(to: b)
                y.intersection(with: yj)
                
                
                
                //if !b.contains(j) && (attributeSets.get(index: j).intersected(yj)).isSubset(of: b.intersected(yj)) {
                if !b.contains(j) && x.isSubset(of: y) {
                    //let c = concept.objects.intersected(context!.down(attribute: j))
                    c.setValues(to: context!.attributes[j])
                    c.intersection(with: concept.objects)
                    
                    let d = getattributeSet()
                    context?.up(objects: c, into: d)
                
                    k.setValues(to: b)
                    k.intersection(with: yj)
                    
                    l.setValues(to: d)
                    l.intersection(with: yj)
                    
                    //if b.intersected(yj) == d.intersected(yj) {
                    if  k == l {
                        conceptQueue.enqueue(FormalConcept(objects: BitSet(bitset: c), attributes: d))
                        attributeQueue.enqueue(j + 1)
                    } else {
                        setMy.set(index: j, set: d)
                    }
                }
            }
            
            while !conceptQueue.isEmpty {
                parallelGenerateFrom(concept: conceptQueue.dequeue()!,
                                     attribute: attributeQueue.dequeue()!,
                                     attributeSets: setMy,
                                     depthLevel: depthLevel + 1)
            }
        }
        
        
        
        if depthLevel == 0 {
            DispatchQueue.concurrentPerform(iterations: numberOfThreads) { (id) in
                let conceptsQueue = self.conceptQueues[id]
                let attributesQueue = self.attributeQueues[id]
                let failedAttributes = self.failedAttributes[id]

                
                for _ in 0..<conceptsQueue.count {
                    let concept = conceptsQueue.dequeue()!
                    let attribute = attributesQueue.dequeue()!
                    
                    self.fastGenerateFrom(concept: concept,
                                          attribute: attribute,
                                          attributeSets: failedAttributes.dequeue()!,
                                          processId: id)
                }
            }
        }
    }
    
    func fastGenerateFrom(concept: FormalConcept, attribute: Attribute, attributeSets: UpdatableSet, processId: Int) {
        store(concept: concept)
        
        if concept.attributes == context!.allAttributes || attribute >= context!.attributeCount {
            return
        }
        
        let conceptQueue = Queue<FormalConcept>()
        let attributeQueue = Queue<Attribute>()
        var setMy = attributeSets
        
        let yj = self.yj[processId]
        let k = self.k[processId]
        let l = self.l[processId]
        let x = self.x[processId]
        let y = self.y[processId]
        let b = self.b[processId]
        let c = self.c[processId]
        
        for j in attribute..<context!.attributeCount {
            yj.addMany(0..<j)
            b.setValues(to: concept.attributes)
            
            x.setValues(to: attributeSets.get(index: j))
            x.intersection(with: yj)
            
            y.setValues(to: b)
            y.intersection(with: yj)
            
            
            if !b.contains(j) && x.isSubset(of: y) {
                c.setValues(to: context!.attributes[j])
                c.intersection(with: concept.objects)
                
                let d = getattributeSet()
                context?.up(objects: c, into: d)
                
                
                k.setValues(to: b)
                k.intersection(with: yj)
                
                l.setValues(to: d)
                l.intersection(with: yj)
                
                if  k == l {
                    conceptQueue.enqueue(FormalConcept(objects: getObjectSet(with: c), attributes: d))
                    attributeQueue.enqueue(j + 1)
                } else {
                    setMy.set(index: j, set: d)
                }
            }
        }
        
        while !conceptQueue.isEmpty {
            fastGenerateFrom(concept: conceptQueue.dequeue()!, attribute: attributeQueue.dequeue()!, attributeSets: setMy, processId: processId)
        }
    }
    
}
