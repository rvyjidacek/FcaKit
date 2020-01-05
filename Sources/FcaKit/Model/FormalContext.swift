//
//  FormalContext.swift
//  FCA
//
//  Created by Roman Vyjídáček on 03.06.18.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import Foundation

public class FormalContext {
    
    public var objectNames: [String] = []
    
    public var attributeNames: [String] = []
    
    /// Bitset array where object[x] contains set of attributes for object x.
    public var objects: [BitSet] = []
    
    /// Bitset array where attributes[y] contains set of objects for attribute y.
    public var attributes: [BitSet] = []
    
    public var objectCount: Int{
        return objects.count
    }
    
    public var attributeCount: Int {
        return attributes.count
    }
    
    public var allAttributes: BitSet {
        return BitSet(size: attributeCount, values: 0..<attributeCount)
    }
    
    public var allObjects: BitSet {
        return BitSet(size: objectCount, values: 0..<objectCount)
    }
    
    public var htmlDescription: String {
        var htmlString = "<table>"
        
        for row in 0..<values.count {
            htmlString.append("<tr>")
            for col in 0..<values[row].count {
                htmlString.append("<td>\(values[row][col])</td>")
            }
            htmlString.append("</tr>")
        }
        
        htmlString.append("</table>")
        return htmlString
    }
    
    /// 2D array with binary data. This value is useful for ELL algorithm of BMF
    public var values: Matrix = []
    
    public init(url: URL) throws {
        let stream = InputStream(url: url)!
        let csv = try CSVReader(stream: stream)
        
        var values: [[Int]] = []
        
        while let row = csv.next(){
            let intRow = row.compactMap({ Int($0) })
            
            if !intRow.isEmpty {
                values.append(intRow)
            }
        }
        
        self.values = values
        self.objects = parseObjects(from: values)
        self.attributes = parseAttributes(from: values)
        self.allAttributes.setAll()
    }
    
    
    public init(values: [[Int]]) {
        self.values = values
        self.objects = parseObjects(from: values)
        self.attributes = parseAttributes(from: values)
        self.allAttributes.setAll()
    }
    
    fileprivate func parseObjects(from values: [[Int]]) -> [BitSet] {
        return values.map({ BitSet(size: values.first!.count, values: $0.enumerated()
                     .compactMap({ $0.element == 1 ? $0.offset : nil }))})
    }
    
    fileprivate func parseAttributes(from values: [[Int]]) -> [BitSet] {
        var result: [BitSet] = []
        for attribute in 0..<values.first!.count {
            let objects = BitSet(size: values.count)
            for object in 0..<values.count {
                if values[object][attribute] == 1 {
                    objects[object] = true
                }
            }
            result.append(objects)
        }
        return result
    }
    
    public func up(objects: BitSet) -> BitSet {
        return up(objects: objects, upto: attributeCount)
    }
    
    public func up(object: Object) -> BitSet {
        return BitSet(bitset: objects[Int(object)])
    }
    
    public func down(attribute: Attribute) -> BitSet {
        return BitSet(bitset: attributes[Int(attribute)])
    }
    
    public func down(attribute: Attribute, into: BitSet) {
        into.setValues(to: attributes[Int(attribute)])
    }
    
    
    public func down(attributes: BitSet) -> BitSet {
        let result = allObjects
        
        for attribute in attributes {
            result.intersection(with: self.attributes[Int(attribute)])
            if result.isEmpty { break }
        }
        return result
    }
    
    public func down(attributes: BitSet, into: BitSet) {
        into.addMany(0..<objectCount)
        
        for attribute in attributes {
            into.intersection(with: self.attributes[Int(attribute)])
            if into.isEmpty { break }
        }
    }
    
    public func up(objects: CountableRange<Int>) -> BitSet {
        return up(objects: objects, upto: attributeCount)
    }
    
    public func up(objects: BitSet, upto j: Attribute) -> BitSet {
        let result = BitSet(size: attributeCount, values: 0..<j)
        
        for object in objects {
            result.intersection(with: self.objects[Int(object)])
            if result.isEmpty { break }
        }
        return result
    }
    
    private func up<T: Sequence>(objects: T, upto j: Attribute) -> BitSet where T.Element: BinaryInteger {
        let result = BitSet(size: attributeCount, values: 0..<attributeCount)
        
        for object in objects {
            result.intersection(with: self.objects[Int(object)])
            if result.isEmpty { break }
        }
        return result
    }
    
    public func up(objects: BitSet, upto j: Attribute, into: BitSet) {
        into.addMany(0..<j)
        
        for object in objects {
            into.intersection(with: self.objects[Int(object)])
            if into.isEmpty { break }
        }
    }
    
    public func up(objects: BitSet, into: BitSet) {
        into.addMany(0..<attributeCount)
        
        for object in objects {
            into.intersection(with: self.objects[Int(object)])
            if into.isEmpty { break }
        }
    }
    
    public func upAndDown(objects: BitSet) -> BitSet {
        return down(attributes: up(objects: objects))
    }
    
    public func downAndUp(attributes: BitSet) -> BitSet {
        return up(objects: down(attributes: attributes))
    }
    
    public func attributeSet() -> BitSet {
        return BitSet(size: self.attributeCount)
    }
    
    public func objectSet() -> BitSet {
        return BitSet(size: self.objectCount)
    }
    
    public func atributeSet(withValues values: CountableRange<Int>) -> BitSet {
        return BitSet(size: self.attributeCount, values: values)
    }
    
    public func objectSet(withValues values: CountableRange<Int>) -> BitSet {
        return BitSet(size: self.objectCount, values: values)
    }
    
    public func has(object: Object, attribute: Attribute) -> Bool {
        return values[object][attribute] == 1
    }
    
    public func get(IthAttribute offset: Int, forObject object: Object) -> Attribute {
        var counter = offset
        for attribute in 0..<Attribute(values[object].count) {
            if counter == 0 { return attribute }
            if has(object: object, attribute: attribute) { counter -= 1 }
        }
        fatalError("Unable to get attribute at \(offset)")
    }
}
