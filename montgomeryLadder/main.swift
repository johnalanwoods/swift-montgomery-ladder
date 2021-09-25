//
//  main.swift
//  montgomeryLadder
//
//  Created by John Woods on 20/09/2021.
//

import BigInt
import Darwin
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
typealias ECPoint = (x: BigInt, y: BigInt)

let f = BigInt("57896044618658097711785492504343953926634992332820282019728792003956564819949") // 2^255-19
let a = BigInt("486662") // y^2 = x^3+486662x^2+x
let b = BigInt("1")

func montgomeryPointAddition(point1 p1:ECPoint, point2 p2:ECPoint) -> ECPoint {
    var p3:ECPoint = (0,0)
    if (p1 == p2) {
        print("error: p1 == p2"); return p3
    } else {
        let λ = (p2.y-p1.y)*(p2.x-p1.x).inverse(f)!
        p3.x = (b*λ.power(2)-a-p1.x-p2.x).modulus(f)
        p3.y = (λ*(p1.x-p3.x)-p1.y).modulus(f)
        return (p3.x,p3.y)
    }
}

func montgomeryPointDouble(point p:ECPoint) -> ECPoint {
    var r:ECPoint = (0,0)
    let λ = (3*p.x.power(2)+(2*a*p.x)+1)*(2*b*p.y).inverse(f)!
    r.x = (b*λ.power(2)-a-2*p.x).modulus(f)
    r.y = ((λ*(p.x-r.x))-p.y).modulus(f)
    return (r)
}

var G = ECPoint(x: "9", y: "14781619447589544791020593568409986887264606134616475288964881837755586237401") //25519 generator

func montgomeryLadder(point p: ECPoint, scalar k: (BigInt)) -> ECPoint {
    var r0 = p
    var r1 = montgomeryPointDouble(point: p)
	let binary = String(String(k, radix: 2).reversed())
    var kWidth = binary.length-2
    while(kWidth >= 0) {
        if(binary[kWidth]=="0"){
			r1 = (montgomeryPointAddition(point1: r0, point2: r1))
			r0 = (montgomeryPointDouble(point: r0))
        } else {
            r0 = (montgomeryPointAddition(point1: r0, point2: r1))
            r1 = (montgomeryPointDouble(point: r1))
		}
        kWidth-=1
    }
    return r0
}

print(montgomeryLadder(point: G, scalar: "6828264568850102822308841164815750172422758260273923275834033954251369251494500977638852462738639436223"))
