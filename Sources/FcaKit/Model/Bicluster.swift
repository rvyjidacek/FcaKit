//
//  Bicluster.swift
//  FcaKit
//
//  Created by Roman Vyjídáček on 05.01.2021.
//

import Foundation

public func == (lhs: Bicluster, rhs: Bicluster) -> Bool {
    return lhs.attributes == rhs.attributes && lhs.objects == rhs.objects
}

public class Bicluster: CustomStringConvertible, Hashable, Codable {
    public let objects: BitSet
    public let attributes: BitSet
    
    public var size: Double { Double(objects.count * attributes.count) }
    
    public init(objects: BitSet, attributes: BitSet) {
        self.objects = objects
        self.attributes = attributes
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objects.hashValue)
        hasher.combine(attributes.hashValue)
    }
    
    public var description: String {
        return "⟨\(objects),\(attributes)⟩"
    }
    
    public var latexDescription: String {
        return "$\\langle\(objects),\(attributes)\\rangle$".replacingOccurrences(of: "{", with: "\\{").replacingOccurrences(of: "}", with: "\\}")
    }
    
    public lazy var tuples: CartesianProduct = {
        return objects.cartesianProduct(with: attributes)
    }()
    
    public var cartesianProduct: CartesianProduct {
           CartesianProduct(a: objects, b: attributes)
    }
    
}
