//
//  FormalConcept.swift
//  FCA
//
//  Created by Roman Vyjídáček on 11.06.18.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import Foundation

public func == (lhs: FormalConcept, rhs: FormalConcept) -> Bool {
    return lhs.attributes == rhs.attributes && lhs.objects == rhs.objects
}

public class FormalConcept: CustomStringConvertible, Hashable, Codable {
    public let objects: BitSet
    public let attributes: BitSet
    
    public init(objects: BitSet, attributes: BitSet) {
        self.objects = objects
        self.attributes = attributes
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objects.hashValue ^ attributes.hashValue)
    }
    
    public var description: String {
        return "⟨\(objects),\(attributes)⟩"
    }
    
    public var latexDescription: String {
        return "$\\langle\(objects),\(attributes)\\rangle$".replacingOccurrences(of: "{", with: "\\{").replacingOccurrences(of: "}", with: "\\}")
    }
    
    public lazy var tuples: Set<Tuple> = {
        return objects.cartesianProduct(with: attributes)
    }()
    
    public lazy var cartesianProduct: CartesianProduct = { CartesianProduct(a: objects, b: attributes) }()
    
    
}

