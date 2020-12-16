//
//  Coder.swift
//  OAuth2
//
//  Created by Adir Burke on 2/12/20.
//

import Foundation
//import Foundation
import CodableWrappers

public protocol OptionalInitable {
    init?(_ value : String)
}

extension Int : OptionalInitable {}
extension Double : OptionalInitable {}
extension UInt : OptionalInitable {}
extension String : OptionalInitable {}
extension Data : OptionalInitable {
    public init?(_ value: String) {
        print(value)
        if let data = decodeBase64String(base64Str: value, decodingTable: createDecodingTable(gStandardEncodingTable)) {
            #warning("Might need to be base64")
            self = data
        } else {
            return nil
        }
    }
}

public struct Coder<T : Codable &  OptionalInitable> : StaticCoder {
    public static func decode(from decoder: Decoder) throws -> T? {
        if let directValue = try? T(from: decoder) {
            return  directValue
        } else if let fromValue = try? String(from: decoder),
            let directValue = T.init(fromValue) {
            return directValue
        }
        return nil
    }
   public  static func encode(value: T?, to encoder: Encoder) throws {
        return try value.encode(to: encoder)
    }
}


func decodeBase64String(base64Str:String, decodingTable:[UInt8] ) -> Data? {
    // The input string should be plain ASCII
    let cString = base64Str.compactMap { $0.asciiValue }
    
    var inputLength = cString.count
    if inputLength % 4 != 0 {return nil}
    if inputLength == 0 {return Data()}
    while  inputLength > 0 && cString[inputLength - 1] == 61 {
        inputLength -= 1
    }
    let outputLength = inputLength * 3 / 4
    
    var data = Data(capacity: outputLength)
    var inputPoint = 0
    var outputPoint = 0
    let table = decodingTable
    
    while  inputPoint < inputLength {
        let i0  = cString[inputPoint]
        inputPoint += 1
        let i1 = cString[inputPoint]
        inputPoint += 1
        let i2 = inputPoint < inputLength ? cString[inputPoint] : 65 // 'A' will decode to \0
        inputPoint += 1
        let i3 = inputPoint < inputLength ? cString[inputPoint] : 65
        inputPoint += 1
        
        if i0 == 95 || i1 == 95 || i2 == 95 || i3 == 95 {
            
        }
        
        let t = (table[Int(i0)] << 2) | (table[Int(i1)] >> 4)
        data.append(t)
        
        outputPoint += 1
        if outputPoint < outputLength {
            data.append(UInt8( ((table[Int(i1)] & 0xF) << 4) | (table[Int(i2)] >> 2)))
            outputPoint += 1
        }
        if outputPoint < outputLength {
            let t = ((table[Int(i2)] & 0x3) << 6) | table[Int(i3)]
            data.append(UInt8(t))
            outputPoint += 1
        }
    }
    
    return data
}

func createDecodingTable(_ string : String) -> [UInt8] {
    var returnValue = [UInt8]()
    for _ in 0...127 {
        returnValue.append(0)
    }
    for (i,c) in string.enumerated() {
        returnValue[Int(c.asciiValue!)] = UInt8(i)
    }
    return returnValue
}

let gStandardEncodingTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
