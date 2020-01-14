
// a class that can be used as an efficient set container for non-negative integers
public final class BitSet: Sequence, Equatable, CustomStringConvertible,
Hashable, ExpressibleByArrayLiteral {
    var capacity = 8 // how many words have been allocated
    var wordcount = 0 // how many words are used
    var size = 0 // Max value which can be interted into a set
    
    public var data: UnsafeMutablePointer<UInt64> // we are going to manage our own memory
    
    public static var allocations = 0
    public static var deallocations = 0
    
    // copy construction
    public init (bitset other: BitSet) {
        BitSet.allocations += 1
        capacity = other.capacity
        wordcount = other.wordcount
        size = other.size
        data = UnsafeMutablePointer<UInt64>.allocate(capacity:capacity)
        for i in 0..<capacity {
            data[i] = other.data[i]
        }
    }
    
    public init() {
        BitSet.allocations += 1
        data = UnsafeMutablePointer<UInt64>.allocate(capacity:capacity)
        wordcount = 0
        for k in 0..<wordcount {
            data[k] = 0
        }
    }
    
    public init(size: Int) {
        BitSet.allocations += 1
        wordcount = (size / 64) + 1
        capacity = wordcount
        self.size = size
        data = UnsafeMutablePointer<UInt64>.allocate(capacity:capacity)
        for k in 0..<wordcount {
            data[k] = 0
        }
    }
    
    public init(size: Int, values: CountableRange<Int>) {
        BitSet.allocations += 1
        wordcount = (size / 64) + 1
        capacity = wordcount
        self.size = size
        data = UnsafeMutablePointer<UInt64>.allocate(capacity:capacity)
        for k in 0..<wordcount {
            data[k] = 0
        }
        addMany(values)
    }
    
    
    deinit {
        BitSet.deallocations += 1
        data.deallocate()
    }
    
    // make a bitset containing the list of integers, all values must be non-negative
    // adding the value i to the bitset will cause the use of least (i+8)/8 bytes
    public init(_ allints: Int...) {
        var mymax = 0
        for i in allints { mymax = mymax < i ? i : mymax }
        wordcount = (mymax+63)/64 + 1
        capacity = wordcount
        data = UnsafeMutablePointer<UInt64>.allocate(capacity:wordcount)
        for k in 0..<wordcount {
            data[k] = 0
        }
        addMany(allints)
    }
    
    public init(size: Int, values: [Int]) {
        wordcount = size / 64 + 1
        capacity = wordcount
        self.size = size
        data = UnsafeMutablePointer<UInt64>.allocate(capacity:wordcount)
        for k in 0..<wordcount {
            data[k] = 0
        }
        addMany(values)
    }
    
    
    
    
    // initializing from array literal
    public init(arrayLiteral elements: Int...) {
        var mymax = 0
        for i in elements { mymax = mymax < i ? i : mymax }
        wordcount = (mymax+63)/64 + 1
        capacity = wordcount
        data = UnsafeMutablePointer<UInt64>.allocate(capacity:wordcount)
        for k in 0..<wordcount {
            data[k] = 0
        }
        for i in elements { insert(i) }
    }
    
    public typealias Element = Int
    
    // return an empty bitset
    public static var allZeros: BitSet { return BitSet() }
    
    public func cartesianProduct(with bitset: BitSet) -> CartesianProduct {
        return CartesianProduct(a: self, b: bitset)
    }
    
    
    public func hash(into hasher: inout Hasher) {
        let b: UInt64 = 31
        var hash: UInt64 = 0
        for i in 0..<wordcount {
            let w = data[i]
            hash = hash &* b &+ w
        }
        hash = hash ^ ( hash >> 33)
        hash = hash &* 0xff51afd7ed558ccd
        hash = hash ^ ( hash >> 33)
        hash = hash &* 0xc4ceb9fe1a85ec53
        hasher.combine(Int(truncatingIfNeeded: hash))
    }
    
    // presents a string representation of the bitset
    public var description: String {
        guard !isEmpty else { return "∅" }
        let ret = self.map { $0.description }.joined(separator: ", ")
        return "{\(ret)}"
    }
    
    // count how many values have been stored in the bitset (this function is not free of computation)
    public var count: Int {
        var sum: Int = 0
        for i in 0..<wordcount {
            let w = data[i]
            sum = sum &+ w.nonzeroBitCount
        }
        return sum
    }
    
    // add a value to the bitset, all values must be non-negative
    // adding the value i to the bitset will cause the use of least (i+8)/8 bytes
    public func insert(_ element: Int) {
        let index = element >> 6
        if index >= self.wordcount { increaseWordCount( index + 1) }
        data[index] |= 1 << (UInt64(element & 63))
    }
    
    // add all the values  to the bitset
    // adding the value i to the bitset will cause the use of least (i+8)/8 bytes
    public func addMany(_ allints: [Int]) {
        var mymax = 0
        for i in allints { mymax = mymax < i ? i : mymax }
        let maxindex = mymax >> 6
        if maxindex >= self.wordcount {
            increaseWordCount(maxindex + 1)
        }
        for i in allints { insert(i) }
    }
    
    // check that a value is in the bitset, all values must be non-negative
    public func contains(_ value: Int) -> Bool {
        let index = value >> 6 // This line of code converts value to the item's index in the bit array
        if index >= self.wordcount { return false }
        return data[index] & (1 << (UInt64(value & 63))) != 0
    }
    
    public subscript(value: Int) -> Bool {
        get {
            return contains(value)
        }
        set(newValue) {
            if newValue { insert(value)} else { remove(value) }
        }
    }
    
    // compute the intersection (in place) with another bitset
    public func intersection(with other: BitSet) {
        let mincount = Swift.min(self.wordcount, other.wordcount)
        for i in 0..<mincount { data[i] &= other.data[i] }
        for i in mincount..<self.wordcount { data[i] = 0 }
    }
    
    public func intersected(_ other: BitSet) -> BitSet {
        let result = BitSet(bitset: self)
        result.intersection(with: other)
        return result
    }
    
    // compute the size of the intersection with another bitset
    public func intersectionCount(_ other: BitSet) -> Int {
        let mincount = Swift.min(self.wordcount, other.wordcount)
        var sum = 0
        for i in 0..<mincount { sum = sum &+ ( data[i] & other.data[i]).nonzeroBitCount }
        return sum
    }
    
    // compute the union (in place) with another bitset
    public func union(with other: BitSet) {
        let mincount = Swift.min(self.wordcount, other.wordcount)
        for  i in 0..<mincount {
            data[i] |= other.data[i]
        }
        if other.wordcount > self.wordcount {
            self.matchWordCapacity(other.wordcount)
            self.wordcount = other.wordcount
            for i in mincount..<other.wordcount {
                data[i] = other.data[i]
            }
        }
    }
    
    public func unioned(_ other: BitSet) -> BitSet {
        let result = BitSet(bitset: self)
        result.union(with: other)
        return result
    }
    
    // compute the size union  with another bitset
    public func unionCount(_ other: BitSet) -> Int {
        let mincount = Swift.min(self.wordcount, other.wordcount)
        var sum = 0
        for  i in 0..<mincount {
            sum = sum &+ (data[i] | other.data[i]).nonzeroBitCount
        }
        if other.wordcount > self.wordcount {
            for i in mincount..<other.wordcount {
                sum = sum &+ (other.data[i]).nonzeroBitCount
            }
        } else {
            for i in mincount..<self.wordcount {
                sum = sum &+ (data[i]).nonzeroBitCount
            }
        }
        return sum
    }

    public func differenced(_ other: BitSet) -> BitSet {
        let result = BitSet(bitset: self)
        result.difference(other)
        return result
    }
    
    
    // compute the difference (in place) with another bitset
    public func difference(_ other: BitSet) {
        let mincount = Swift.min(self.wordcount, other.wordcount)
        for  i in 0..<mincount {
            data[i] &= ~other.data[i]
        }
    }
    
    // compute the size of the difference with another bitset
    public func differenceCount(_ other: BitSet) -> Int {
        let mincount = Swift.min(self.wordcount, other.wordcount)
        var sum = 0
        for  i in 0..<mincount {
            sum = sum &+ ( data[i] & ~other.data[i]).nonzeroBitCount
        }
        for i in mincount..<self.wordcount {
            sum = sum &+ (data[i]).nonzeroBitCount
        }
        return sum
    }
    
    // remove a value, must be non-negative
    public func remove(_ value: Int) {
        let index = value >> 6
        if index < self.wordcount {
            data[index] &= ~(1 << UInt64(value & 63))
        }
    }
    
    // remove a value, if it is present it is removed, otherwise it is added, must be non-negative
    public func flip(_ value: Int) {
        let index = value >> 6
        if index < self.wordcount {
            data[index] ^= 1 << UInt64(value & 63)
        } else {
            increaseWordCount(index + 1)
            data[index] |= 1 << UInt64(value & 63)
        }
    }
    
    // remove many values, all must be non-negative
    public func removeMany(_ allints: Int...) {
        for i in allints { remove(i) }
    }
    
    // return the memory usage of the backing array in bytes
    public func memoryUsage() -> Int {
        return self.capacity * 8
    }
    
    // check whether the value is empty
    public var isEmpty: Bool {
        for i in 0..<wordcount {
            let w = data[i]
            if w != 0 { return false }
        }
        return true
    }
    
    
    public func setValues(to bitset: BitSet) {
        for i in 0..<wordcount {
            self.data[i] = bitset.data[i]
        }
    }
    
    // remove all elements, optionally keeping the capacity intact
    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        wordcount = 0
        if !keepCapacity {
            data.deallocate()
            capacity = 8 // reset to some default
            data = UnsafeMutablePointer<UInt64>.allocate(capacity:capacity)
        }
    }
    
    private static func nextCapacity(mincap: Int) -> Int {
        return 2 * mincap
    }
    
    // Check is self is subset od bitset parameter.
    public func isSubset(of bitset: BitSet) -> Bool {
        for i in 0..<bitset.wordcount {
            let value = self.data[i] & bitset.data[i]
            if value != self.data[i] { return false }
        }
        return true;
        
        //return count == (self.intersected(bitset)).count
    }
    
    // caller is responsible to ensure that index < wordcount otherwise this function fails!
    func increaseWordCount(_ newWordCount: Int) {
        if(newWordCount <= wordcount) {
            print(newWordCount, wordcount)
        }
        if newWordCount > capacity {
            growWordCapacity(BitSet.nextCapacity(mincap : newWordCount))
        }
        for i in wordcount..<newWordCount {
            data[i] = 0
        }
        wordcount = newWordCount
    }
    
    func growWordCapacity(_ newcapacity: Int) {
        let newdata = UnsafeMutablePointer<UInt64>.allocate(capacity:newcapacity)
        for i in 0..<self.wordcount {
            newdata[i] = self.data[i]
        }
        data.deallocate()
        data = newdata
        self.capacity = newcapacity
    }
    
    func matchWordCapacity(_ newcapacity: Int) {
        if newcapacity > self.capacity {
            growWordCapacity(newcapacity)
        }
    }
    
    // checks whether the two bitsets have the same content
    public static func == (lhs: BitSet, rhs: BitSet) -> Bool {
        guard lhs.size == rhs.size else { return false }
        
        for i in 0..<lhs.wordcount {
            if lhs.data[i] != rhs.data[i] { return false }
        }
        
        return true
        /*if lhs.wordcount > rhs.wordcount {
            for  i in rhs.wordcount..<lhs.wordcount  where lhs.data[i] != 0 {
                return false
            }
        } else if lhs.wordcount < rhs.wordcount {
            for i in lhs.wordcount..<rhs.wordcount where  rhs.data[i] != 0 {
                return false
            }
        }
        let mincount = Swift.min(rhs.wordcount, lhs.wordcount)
        for  i in 0..<mincount where rhs.data[i] != lhs.data[i] {
            return false
        }
        return true*/
    }
    
    // Set all items of set to 1
    public func setAll() {
        for i in 1...wordcount {
            if (i * 63) <= size {
                data[i - 1] = UInt64.max
            } else {
                let cellMaxValue = i * 64
                let shiftConstant = cellMaxValue - size
                data[i - 1] = UInt64.max >> shiftConstant
            }
        }
    }
    
    public func erase() {
        for i in 0..<wordcount {
            data[i] = 0
        }
    }
    
    public func element() -> Int? {
        var iterator = self.makeIterator()
        return iterator.next()
    }
    
    public func element(at index: Int) -> Int? {
        var elementIndex = 0
        
        for element in self {
            if elementIndex == index { return element }
            elementIndex += 1
        }
        
        return nil
    }
    
    public func addMany(_ range: CountableRange<Int>) {
        let wordUpperBound: Int = 64
        var upperBound = range.upperBound
        
        for i in 0..<wordcount {
            if upperBound >= wordUpperBound { data[i] = UInt64.max }
            else if upperBound < wordUpperBound { data[i] = mask(of: upperBound) }
            else { data[i] = 0 }
            
            if upperBound >= wordUpperBound {
                upperBound -= wordUpperBound
            } else {
                upperBound = 0
            }
        }
    }
    
    private func mask(of count: Int) -> UInt64 {
        var mask: UInt64 = 1
        mask = mask << count
        mask -= 1
        //mask <<= 64 - count
        return mask
    }
}


extension BitSet {
    
    public func makeIterator() -> BitsetIterator {
        return BitsetIterator(self)
    }
}


public struct BitsetIterator: IteratorProtocol {
    let bitset: BitSet
    var value: Int = -1
    
    init(_ bitset: BitSet) {
        self.bitset = bitset
    }
    
    public mutating func next() -> Int? {
        value = value &+ 1
        var x = value >> 6
        if x >= bitset.wordcount {
            return nil
        }
        var w = bitset.data[x]
        w >>= UInt64(value & 63)
        if w != 0 {
            value = value &+ w.trailingZeroBitCount
            return value
        }
        x = x &+ 1
        while x < bitset.wordcount {
            let w = bitset.data[x]
            if w != 0 {
                value = x &* 64 &+ w.trailingZeroBitCount
                return value
            }
            x = x &+ 1
        }
        return nil
    }
}

public struct BitSetIterator: IteratorProtocol {
    
    private static var subsets: [[Int]] = []
    
    private let bitset: BitSet
    
    public typealias Element = Int
    
    init(_ bitset: BitSet) {
        self.bitset = bitset
        
        if BitSetIterator.subsets.isEmpty {
            BitSetIterator.initSubsets()
        }
    }
    
    private static func initSubsets() {
        subsets = [[Int]](repeating: [], count: 65536)
        for i in 0...65535 {
            let number: Int = i
            var values: [Int] = []
            
            let one  = 1
            for bit in 0...15 {
                if (one << bit) & number >= 1 {
                    values.append(bit)
                }
            }
            
            subsets[number] = values
        }
    }
    
    private let uint16Max: UInt64 = 65535
    
    private var dataIndex: Int = 0
    
    private var values: [Int] = []
    
    private var dataShift: Int = -16
    
    private var offset: Int = -16
    
    private var valuesIndex: Int = 0
    
    
    private var itemsValues: [[Int]]! = nil // [[], [], [], []]
    private var itemIndex: Int = 0
    private var valueIndex: Int = 0
    
    public mutating func next() -> Int? {
        if itemsValues == nil {
            itemsValues = [[Int]](repeating: [], count: bitset.wordcount << 2)
            var beginIndex = 0
            for i in 0..<bitset.wordcount {
                let data = bitset.data[i]
                itemsValues[beginIndex] = BitSetIterator.subsets[Int(data & uint16Max)]
                itemsValues[beginIndex + 1] = BitSetIterator.subsets[Int((data >> 16) & uint16Max)]
                itemsValues[beginIndex + 2] = BitSetIterator.subsets[Int((data >> 32) & uint16Max)]
                itemsValues[beginIndex + 3] = BitSetIterator.subsets[Int((data >> 48) & uint16Max)]
                beginIndex += 4
            }
        }
        
        for i in itemIndex..<itemsValues.count {
            if !(itemsValues[i].isEmpty) {
                let value = itemsValues[itemIndex][valueIndex] + (16 * itemIndex)
                valueIndex = (valueIndex + 1) % itemsValues[itemIndex].count
                itemIndex = valueIndex == Int.zero ? itemIndex + 1 : itemIndex
                return value
            }
            itemIndex += 1
        }
        return nil
    }
    

//    public mutating func next() -> Int? {
//        guard !(bitset.isEmpty) else { return nil }
//
//        if valuesIndex == 0 {
//            dataIndex += dataShift >= UInt64.bitWidth ? 1 : 0
//            dataShift += 16
//            offset += 16
//            values = BitSetIterator.subsets[Int((bitset.data[dataIndex] >> dataShift) & uint16Max)]!
//
//            while values.isEmpty {
//                dataShift += 16
//                if dataShift >= UInt64.bitWidth {
//                    dataIndex += 1
//                    dataShift = 0
//                }
//
//                if bitset.wordcount <= dataIndex { return nil }
//                values = BitSetIterator.subsets[Int((bitset.data[dataIndex] >> dataShift) & uint16Max)]!
//            }
//        }
//
//        let val = values[valuesIndex] + offset
//        valuesIndex = (valuesIndex + 1) % values.count
//        return val > bitset.size ? nil : val
//     }

    
}

extension BitSet: Codable {
 
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(capacity, forKey: .capacity)
        try container.encode(wordcount, forKey: .wordcount)
        try container.encode(size, forKey: .size)
        
        var values = [UInt64](repeating: 0, count: capacity)
        
        for i in 0..<capacity { values[i] = data[i] }
        
        try container.encode(values, forKey: .data)
    }
    
    public convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.capacity = try container.decode(Int.self, forKey: .capacity)
        self.wordcount = try container.decode(Int.self, forKey: .wordcount)
        self.size = try container.decode(Int.self, forKey: .size)
        data = UnsafeMutablePointer<UInt64>.allocate(capacity:capacity)
        
        let values = try container.decode([UInt64].self, forKey: .data)
        
        for i in 0..<capacity { data[i] = values[i] }
    }
    
    private enum CodingKeys: String, CodingKey {
        case capacity
        case wordcount
        case size
        case data
    }
}
