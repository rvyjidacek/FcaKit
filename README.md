# FcaKit

FcaKit is Swift library implementing Formal Concept Analysis data mining method. It works with macOS, iOS and Linux.  


## What is Formal Concept Analysis?

Formal concept analysis (FCA) is a principled way of deriving a concept hierarchy or formal ontology from a collection of objects and their properties. Each concept in the hierarchy represents the objects sharing some set of properties; and each sub-concept in the hierarchy represents a subset of the objects (as well as a superset of the properties) in the concepts above it. The term was introduced by Rudolf Wille in 1980, and builds on the mathematical theory of lattices and ordered sets that was developed by Garrett Birkhoff and others in the 1930s.

[https://en.wikipedia.org/wiki/Formal_concept_analysis](https://en.wikipedia.org/wiki/Formal_concept_analysis)

## More References
*  Ganter B., Wille R. Formal Concept Analysis. Mathematical Foundations. Springer, Berlin, 1999. ISBN 3-540-62771-5
*  Carpineto C., Romano G. Concept Data Analysis : Theory and Applications. John Wiley & Sons, 2004. ISBN 0-470-85055-8
*  Bělohlávek R., Introduction to Formal Concept Analysis, Olomouc 2008

## Implemented  FCA Algorithms
1. NextClosure
2. UpperNeighbor
3. Close by One (CbO)
4. Fast Close by One (FCbO)
5. Parallel Close by One (PCbO)
6. Parallel Fast Close by One (PFCbO)
7. ELL
8. In-Close2
9. In-Close4

Benchamrks can be found [here](Benchmarks.md).

## Implemented BMF Algorithms
1. GreCon
2. SortGreCon
3. GreCon 2.0
4. GreConD


## Build
You can build FcaKit using Xcode. If you are Linux user you can use Swift Package Manager to build. 

```
    swift build -c release
```

## Add as Dependency
You can use FcaKit library in your Swift package. Add FcaKit as dependency as in the following example.
```Swift
    // swift-tools-version:5.1
    // The swift-tools-version declares the minimum version of Swift required to build this package.

    import PackageDescription

    let package = Package(
        name: "Application",
        platforms: [ .macOS(.v10_12), ], // This line is necessary. 
        dependencies: [
        .package(url: "https://github.com/rvyjidacek/FcaKit.git",  from: "1.0.0"),
        ],
        targets: [
            .target(
                name: "Application",
                dependencies: ["FcaKit"]), // Add FcaKit as dependecy here
            .testTarget(
                name: "ApplicationTests",
                dependencies: ["Application", "FcaKit"]), // Add FcaKit as dependecy here
        ]
    )
```

When you add dependency you have to update your package using:

```Swift
    swift package update
```

This command builds FcaKit for release and executable binary you can find in .build/release/fca. Also you can user prepared script called build which builds FcaKit and move binary to current folder.

## Usage

### BitSet

#### Initialization
```Swift
    // Initialize an empty bitset of given size. Size is maximal number which a set can contain. 
    let a = BitSet(size: 100)
    
    // You can also create a bitset with values
    BitSet(size: 100, values: [1, 2, 3, 5, 19]) // array
    BitSet(size: 100, values: 0..<50) // range        
```

#### Operations
```Swift
    let a = BitSet(size: 10, values: [1, 2, 3, 4, 5])
    let b = BitSet(size: 10, values: 0..<10)
    
    // Intersection
    a.intersection(with: a)
    a &= b
    
    let c = a.intersected(b) 
    let d = a & b
    
    // Union
    a.union(with: a)
    a |= b
    
    let c = a.unioned(b) 
    let d = a | b
    
    // Difference
    a.difference(b)
    a -= b
    
    let c = a - b
```
#### Formal Context
Is tuple ⟨X, Y, I⟩ where X is set of object, Y is set of attributes and I ⊆ X ⨉ Y and if for x ∈ X and y ∈ Y we have ⟨x, y⟩ ∈ I we say that object x has and attibute y. In each formal context we have concept forming operators ↑ and ↓ where:
for A ⊆ X and B ⊆ Y we have
A↑ = { y ∈ Y |  x ∈ A and ⟨x, y⟩ ∈ I }
B↓ = { x ∈ X |  y ∈ B and ⟨x, y⟩ ∈ I }

```Swift
    // Initialization with values
    let context = FormalContext(values: [[1, 1, 1], [1, 0, 1], [0, 1, 1], [1, 0, 0]])
    
    // Get common attributes for objects 1 and 3
    let attributes = context.up(objects: BitSet(size: 4, values: [1, 3])) // {0}
    
    // Attributes for object 0
    let y = context.up(object: 0) // {0, 1, 2}
    
    // Get Get objects with attributes 2 and 3
    let objects = context.down(attributes: BitSet(size: 3, values: [2, 3])) // {0, 1, 2}
    
    // Objects with attribute 0
    let x = context.down(attribute: 0) // {0, 1}
    
    // Compute closure
    
    let closure1 = context.upAndDown(objects: BitSet(size: 4, values: [1, 3])) // {0, 1, 3}
    let closure2 = context.downAndUp(attributes: BitSet(size: 3, values: [2, 3])) // {2}
```

#### Formal Concept
Formal concept is 2-tuple ⟨A, B⟩ where  A is set of objects and B is set of attributes and following holds A↑ = B and B↓ = A

#### Computing concepts
For computing concepts of some formal context we have many algorithms. Implemented algorithms can be found in section Implemented Algorithms. Super class of all agorithms is FcaAlgorithm and this class has method count. So you only crreate and Formal Context and pass this one to method count of some algorithm.

```Swift
    let context = // Get formal context for example from csv file
    let algorithm = FCbO() // Create an instance of the algorithm
    
    // Compute concepts
    let concepts = algorithm.count(in: context)
```

### Licence 
Copyright (c) 2019 Roman Vyjidacek

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
