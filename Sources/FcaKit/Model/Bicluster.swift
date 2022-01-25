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
    public var objects: BitSet!
    public var attributes: BitSet!
    public var context: FormalContext?
    
    public var size: Double { Double(objects.count * attributes.count) }
    
    public var coverageSize: Int!
    
    public init(objects: BitSet, attributes: BitSet, context: FormalContext? = nil) {
        self.objects = objects
        self.attributes = attributes
        //self.context = context
        self.coverageSize = self.cartesianProduct.count
    }
    
    enum CodingKeys: String, CodingKey {
        case objects
        case attributes
    }
    
    public init?(coding: String) {
        let sets = coding.split(separator: "-")
        guard !(sets.isEmpty) else { return nil }
        self.objects = self.decodeBitset(code: sets[0].description)
        self.attributes = self.decodeBitset(code: sets[1].description)
        self.context = nil
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objects.hashValue)
        hasher.combine(attributes.hashValue)
    }
    
    public var description: String {
        return "⟨\(objects!),\(attributes!)⟩"
    }
    
    public var latexDescription: String {
        return "$\\langle\(objects!),\(attributes!)\\rangle$".replacingOccurrences(of: "{", with: "\\{").replacingOccurrences(of: "}", with: "\\}")
    }
    
    public var cartesianProduct: CartesianProduct {
        let cartesianProduct = CartesianProduct(a: objects, b: attributes)
        
        if let context = self.context {
            cartesianProduct.intersection(context.cartesianProduct)
        }
        
        return cartesianProduct
    }
    
    public var fullCartesianProduct: CartesianProduct { CartesianProduct(a: objects, b: attributes) }
    
    public func cartesianProduct(into cartesianProduct: CartesianProduct) {
        if let context = self.context {
            cartesianProduct.intersection(context.cartesianProduct)
        }
    }
    
    public func export() -> String {
        // Export Structure
        // <objects-size>;<objects-values>-<attributes-size>;<attributes-values>
        let objectValues = objects.bitArrayValues.map { $0.description }.joined(separator: " ")
        let attributeValues = attributes.bitArrayValues.map { $0.description }.joined(separator: " ")
        return"\(objects.size);\(objectValues)-\(attributes.size);\(attributeValues)"
    }
    
    private func decodeBitset(code: String) -> BitSet {
        let setValues = code.split(separator: ";")
        let bitsetSize = Int(setValues[0])!
        let bitArrayValues = setValues[1].split(separator: " ").map { UInt64($0)! }
        let bitset = BitSet(size: bitsetSize)
        bitset.setBitArrayValues(bitArrayValues)
        return bitset
    }
    
    
}
