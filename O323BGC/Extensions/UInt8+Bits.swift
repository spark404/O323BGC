//
//  UInt8+Bits.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 09/12/2020.
//

import Foundation

extension UInt8 {
    func bit(_ number: Int) -> Bool {
        var tmp = self
        tmp = tmp & (1 << number)
        return tmp > 0
    }
}
