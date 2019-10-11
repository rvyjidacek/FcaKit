//
//  BitSetManager.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 09/01/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class BitSetManager {
    
    private var objectSets: Queue<BitSet>
    private var attributeSets: Queue<BitSet>
    
    private let objectsCount: Int
    private let attributesCount: Int
    
    init(objectsCount: Int, attributesCount: Int) {
        self.objectsCount = objectsCount
        self.attributesCount = attributesCount
        
        objectSets = Queue<BitSet>((0..<objectsCount).map({ (i) -> BitSet in
            return BitSet(size: objectsCount)
        }))
        
        attributeSets = Queue<BitSet>((0..<attributesCount).map({ (i) -> BitSet in
            return BitSet(size: attributesCount)
        }))
    }
    
    public func dequeueObjectSet() -> BitSet {
        let set = objectSets.isEmpty ? BitSet(size: objectsCount) : objectSets.dequeue()!
        set.erase()
        return set
    }
    
    public func dequeueAttributeSet() -> BitSet {
        let set = attributeSets.isEmpty ? BitSet(size: attributesCount) : attributeSets.dequeue()!
        set.erase()
        return set
    }
    
    public func release(set: BitSet) {
        //set.erase()
        if set.size == objectsCount { objectSets.enqueue(set) }
        if set.size == attributesCount { attributeSets.enqueue(set) }
    }
}
