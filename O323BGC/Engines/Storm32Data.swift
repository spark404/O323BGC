//
//  Data.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 11/12/2020.
//

import Foundation

public enum Storm32DataIndex: Int {
    // First five words are equal to the status object
    case State
    case Status
    case Status2
    case Error
    case Voltage
    
    case Millis
    case CycleTime
    case Gx
    case Gy
    case Gz
    case Ax
    case Ay
    case Az
    case Rx
    case Ry
    case Rz
    case Pitch
    case Roll
    case Yaw
    case Pitch2
    case Roll2
    case Yaw2
    case MagYaw
    case LinkYaw
    case PitchCntrl
    case RollCntrl
    case YawCntrl
    case PitchRcIn
    case RollRcIn
    case YawRcIn
    case FunctionsIn
    case AccConfidence
}

public class Storm32Data: NSObject {
    var values: [UInt16]
    
    public init?(data: Data) {
        // 32 UInt16 values
        guard data.count == 32 * 2 else {
            return nil
        }
        
        values = data.withUnsafeBytes {
            [UInt16](UnsafeBufferPointer(start: $0, count: data.count / 2 ))
        }
    }

    public func getUInt16ValueFor(index: Storm32DataIndex) -> UInt16 {
        return values[index.rawValue]
    }

    public func getInt16ValueFor(index: Storm32DataIndex) -> Int16 {
        return Int16(bitPattern: values[index.rawValue])
    }
    
    // This function returns the value as float
    // It also knows about signed vs unsigned values
    public func getFloatValueFor(index: Storm32DataIndex) -> Float {
        if (index.rawValue >= 0 && index.rawValue <= 6 || index == .AccConfidence) {
            // These values are unsigned
            return Float(getUInt16ValueFor(index: index))
        } else {
            return Float(getInt16ValueFor(index: index))
        }
    }
}
