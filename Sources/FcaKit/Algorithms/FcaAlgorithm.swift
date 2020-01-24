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
    
    public var concepts: [FormalConcept] = []
    
    public var conceptsCount: Int = 0
    
    public var closureCount: Int = 0
    
    public var name: String {
        return ""
    }
    
    public init() { }
    
    public func count(in context: FormalContext) -> [FormalConcept] {
        return concepts
    }
    
    func store(concept: FormalConcept) {
        if FcaAlgorithm.saveConcepts {
            concepts.append(concept)
        }
        conceptsCount += 1
    }
}
