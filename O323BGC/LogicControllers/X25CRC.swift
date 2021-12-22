//
//  X25CRC.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 08/12/2020.
//
// Based on https://os.mbed.com/users/shimniok/code/AVC_2012/file/826c6171fc1b/MAVlink/include/checksum.h/
//
import Foundation

class X25CRC: NSObject {
    var accumulator: UInt16

    override init() {
        accumulator = 0xFFFF
    }

    private func reset() {
        accumulator = 0xFFFF
    }

    private func accumulate(data: UInt8) {
        var tmp = data ^ UInt8(accumulator & 0xFF)
        tmp = tmp ^ (tmp << 4)
        let part1 = UInt16(tmp) << 8
        let part2 = UInt16(tmp) << 3
        let part3 = UInt16(tmp) >> 4
        accumulator = (accumulator >> 8) ^ part1 ^ part2 ^ part3
    }

    func calculate(data: Data) -> UInt16 {
        self.reset()

        data.forEach { character in
            accumulate(data: character)
        }

        return accumulator
    }
}
