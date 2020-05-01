//
//  FormalContext.swift
//  FCA
//
//  Created by Roman Vyjídáček on 03.06.18.
//  Copyright © 2018 Palacky University Olomouc. All rights reserved.
//

import Foundation

extension Character {
    
    static let zero:  Character = Character(unicodeScalarLiteral: "0")
    static let nine:  Character = Character(unicodeScalarLiteral: "9")
    static let space: Character = Character(unicodeScalarLiteral: " ")
    static let newLine: Character = Character(unicodeScalarLiteral: "\n")
}

public enum FileFormat {
    case csv
    case fimi
}

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
    
    public lazy var density: Double = {
        let numberOfOnes = values.reduce(into: 0) { result, row in
            result += row.reduce(into: 0, { result, item in result += item })
        }
        
        return (Double(numberOfOnes) / Double(objectCount * attributeCount)) * 100
    }()
    
    public var allObjects: BitSet {
        return BitSet(size: objectCount, values: 0..<objectCount)
    }
    
    public var attributeConcepts: Set<FormalConcept> {
        var result = Set<FormalConcept>(minimumCapacity: attributeCount)
        
        for y in 0..<attributeCount {
            let a = self.down(attribute: y)
            let b = self.attributeSet()
            
            self.up(objects: a, into: b)
            result.insert(FormalConcept(objects: a, attributes: b))
        }
        return result
    }
    
    public var objectConcepts: Set<FormalConcept> {
        var result = Set<FormalConcept>(minimumCapacity: objectCount)
        
        for x in 0..<objectCount {
            let b = up(object: x)
            let a = objectSet()
            
            down(attributes: b, into: a)
            result.insert(FormalConcept(objects: a, attributes: b))
        }
        return result
    }
    
    
    /// 2D array with binary data. This value is useful for ELL algorithm of BMF
    public var values: Matrix = []

    
    public init(url: URL) throws {
        try parseCSV(url)
    }
    
    public init(path: String, format: FileFormat) throws {
        switch format {
        case .csv:
            try parseCSV(URL(fileURLWithPath: path))
        case .fimi: break
            
        }
    }
    
    public init(path: String) {
        var line = 0
        let file = fopen(path, "r")
        var attribute = 0
        
        
        // READ CONTEXT SIZE
        let size = readContextSize(file: file)
        
        objects = (0..<size.rows).map { _ in BitSet(size: size.cols) }
        attributes = (0..<size.cols).map { _ in BitSet(size: size.rows) }
        
        // READ CONTEXT VALUES
        
        while feof(file) == 0 {
            let asciiCode = fgetc(file)
            if asciiCode < 0 { return }
            
            let char: Character = Character(Unicode.Scalar(UInt8(asciiCode)))
            
            if char.asciiValue! == Character.space.asciiValue! {
                objects[line].insert(attribute)
                attributes[attribute].insert(line)
                attribute = 0
                continue
            }
            
            if char.asciiValue! >= Character.zero.asciiValue! &&
                char.asciiValue! <= Character.nine.asciiValue! {
                attribute *= 10
                attribute += Int(char.asciiValue! - Character.zero.asciiValue!)
            }
            
            if char.asciiValue! == Character.newLine.asciiValue! {
                attribute = 0
                line += 1
            }
            
        }
    }
    
    fileprivate func parseCSV(_ url: URL) throws {
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
    
    private func readContextSize(file: UnsafeMutablePointer<FILE>?)  -> (rows: Int, cols: Int) {
        var numberOfObjects = 0
        var numberOfAttributes = 0
        while feof(file) == 0 {
            let asciiCode = fgetc(file)
            let char: Character = Character(Unicode.Scalar(UInt8(asciiCode)))
            
            if char.asciiValue! >= Character.zero.asciiValue! &&
                char.asciiValue! <= Character.nine.asciiValue! {
                numberOfObjects *= 10
                numberOfObjects += Int(char.asciiValue! - Character.zero.asciiValue!)
            } else {
                break
            }
        }
        
        while feof(file) == 0 {
            let asciiCode = fgetc(file)
            let char: Character = Character(Unicode.Scalar(UInt8(asciiCode)))
            
            if char.asciiValue! >= Character.zero.asciiValue! &&
                char.asciiValue! <= Character.nine.asciiValue! {
                numberOfAttributes *= 10
                numberOfAttributes += Int(char.asciiValue! - Character.zero.asciiValue!)
            } else {
                break
            }
        }
        
        return (numberOfObjects, numberOfAttributes)
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
