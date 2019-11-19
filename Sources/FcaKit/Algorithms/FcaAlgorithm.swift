//
//  FcaAlgorithm.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 15/01/2019.
//  Copyright © 2019 Palacky University Olomouc. All rights reserved.
//

import Foundation


public class FcaAlgorithm {
    
    public static var saveConcepts: Bool = true
    
    public enum OutputFormat {
        case Json
        case Object
    }
    
    weak var context: FormalContext?
    
    var objectSetStack = Stack<BitSet>()
    var attributeSetStack = Stack<BitSet>()
    
    public var concepts: Set<FormalConcept> = []
    
    public var conceptsCount: Int = 0
    
    public var name: String {
        return ""
    }
    
    public init() { }
    
    public func count(in context: FormalContext, outputFormat format: OutputFormat = .Object) -> Set<FormalConcept> {
        return concepts
    }
    
    func store(concept: FormalConcept) {
        if FcaAlgorithm.saveConcepts {
            concepts.insert(concept)
        }
        conceptsCount += 1
    }
    
    func getObjectSet(with: BitSet? = nil) -> BitSet {
        if let set = objectSetStack.pop() {
            with == nil ? set.erase() : set.setValues(to: with!)
            return set
        }
        return with == nil ? BitSet(size: context!.objectCount) : BitSet(bitset: with!)
    }
    
    func getattributeSet(with: BitSet? = nil ) -> BitSet {
        if let set = attributeSetStack.pop() {
            with == nil ? set.erase() : set.setValues(to: with!)
            return set
        }
        return with == nil ? BitSet(size: context!.attributeCount) : BitSet(bitset: with!)
    }
    
    
}
