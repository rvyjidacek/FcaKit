////
////  LCM.swift
////
////
////  Created by Roman Vyjídáček on 12.03.2021.
////
//
//import Foundation
//
//public class LCM: FcaAlgorithm {
//
//
//    override public func count(in context: FormalContext) -> [FormalConcept] {
//        return super.count(in: context)
//    }
//
//
//    private func objectsUpUnion(for objects: BitSet) -> BitSet {
//        let result = context!.attributeSet()
//
//        for object in objects {
//            result.union(with: context!.objects[object])
//        }
//        return result
//    }
//
//    private func generateFrom(A: BitSet, B: BitSet, y: Attribute, K: FormalContext) {
//        let N  = objectsUpUnion(for: A)
//        N.difference(B)
//
//        let frequencies = self.frequencies(K: K, N: N)
//
//        for i in N {
//            if i >= y { break }
//
//            if frequencies[i] == A.count { return }
//        }
//
//
//        for i in N {
//            if i <= y { continue }
//
//            if frequencies[i] == A.count {
//                B.insert(i)
//                N.remove(i)
//            }
//        }
//
//        store(concept: FormalConcept(objects: BitSet(bitset: A),
//                                     attributes: BitSet(bitset: B)))
//
//
//        let newK = createConditionalDB(K, A, N, y)
//    }
//
//    private func frequencies(K: FormalContext, N: BitSet) -> [Int] {
//        var frequencies = [Int](repeating: 0, count: K.attributeCount)
//
//        for attribute in 0..<K.attributes.count {
//            if N.contains(attribute) {
//                frequencies[attribute] = K.attributes[attribute].count
//            }
//        }
//
//        return frequencies
//    }
//
//    private func createConditionalDB(_ K: FormalContext, _ A: BitSet, _ N: BitSet, _ y: Attribute) -> FormalContext {
//        let newContext =
//    }
//}
