//
//  Storm32BGCSimulator.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 10/12/2020.
//

import Foundation

struct Storm32BGCSimulator: Storm32BGC {
    func getData() -> Storm32Data? {
        let data = ( "06007098008000000000f03edc0500000400000096fec5e3f11179fe00dfdd14"
                        + "9f0183e9130061fe7d16edff000000000000d20021ff18000000aa057e380000"
                        + "41a66f"
            ).hexaData
        let lastIndex = data.count - 4
        return data[0...lastIndex].decodeToData()
    }

    func getVersion() -> Version? {
        let data = ( "76302e393600000000000000000000004f6c6c69572033323342474300000000"
                        + "76312e3330204631303352430000000060005f0003ff6eee6f"
            ).hexaData

        let lastIndex = data.count - 4
        return data[0...lastIndex].decodeToVersion()
    }

    func getStatus() -> Status? {
        var data = "06007098008000000000419b6f".hexaData
        data[0] = UInt8(Int.random(in: 0..<8))
        let lastIndex = data.count - 4
        return data[0...lastIndex].decodeToStatus()
    }
    
    func getRawParameters() -> Data? {
        return ( "ea01100e4605610014001e002003061814056e0014001e00cc01780584037b0032002800010000000"
            + "e0000000000dd03000000000e00000000004701000000000e000100000018020000000000000e0000"
            + "00000000000a00040000000000e3feb60390012c0105000000000006fffa0090012c0106000000000"
            + "04afcb60390012c010700000001000500050000000000000000000200000000000000000000000000"
            + "e80319000000190002000000fa0001002800320019001e00fa0000000300000000000100000001000"
            + "e06000000000000050000000000000000004700430000000000dc054c046c07000000000000000000"
            + "00000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
            + "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
            + "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
            + "fffffffffffffffffffffffffffdcc46f").hexaData
    }

    func setRawParameters(data: Data) -> Bool {
        guard let originalData = getRawParameters() else {
            return false
        }
        let difference = data.difference(from: originalData)

        print("Sending parameters to device: \(data.hexEncodedString())")
        print("Difference is \(difference)")
        return true
    }

    func resetBoard() {
        print("Simulator - Reset Board")
    }

    func close() {
        print("Simulator - Close")
    }

}
