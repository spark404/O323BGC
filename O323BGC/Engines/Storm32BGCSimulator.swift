//
//  Storm32BGCSimulator.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 10/12/2020.
//

import Foundation

class Storm32BGCSimulator: Storm32BGC {
    override init(fileDescriptor: Int32) {
        super.init(fileDescriptor: -1)
    }
    
    override func getData() -> Storm32Data? {
        let data = "06007098008000000000f03edc0500000400000096fec5e3f11179fe00dfdd149f0183e9130061fe7d16edff000000000000d20021ff18000000aa057e38000041a66f".hexaData
        return Storm32Data(data: data)
    }
    
    override func getVersion() -> Version? {
        let buffer = "76302e393600000000000000000000004f6c6c6957203332334247430000000076312e3330204631303352430000000060005f0003ff6eee6f".hexaData
        
        let version = String(bytes:buffer[0...15].prefix(while: { $0 != 0x0}), encoding: .ascii)!
        let name =  String(bytes:buffer[16...31].prefix(while: { $0 != 0x0}), encoding: .ascii)!
        let board =  String(bytes:buffer[32...47].prefix(while: { $0 != 0x0}), encoding: .ascii)!
        let versionNumber = buffer[48...49].withUnsafeBytes { rawPtr in
            return rawPtr.load(as: UInt16.self)
        }
        let layout = buffer[50...51].withUnsafeBytes { rawPtr in
            return rawPtr.load(as: UInt16.self)
        }
        let capabilities = buffer[52...53].withUnsafeBytes { rawPtr in
            return rawPtr.load(as: UInt16.self)
        }
        return Version(
            version: version,
            versionNumber: versionNumber,
            name: name,
            board: board,
            layout: layout,
            capabilities: capabilities
        )
    }
    
    override func getStatus() -> Status? {
        let data = "06007098008000000000419b6f".hexaData
        return Status.init(data: data)
    }
    
    override func getParameters() -> String? {
        let data = "ea01100e4605610014001e002003061814056e0014001e00cc01780584037b0032002800010000000e0000000000dd03000000000e00000000004701000000000e000100000018020000000000000e000000000000000a00040000000000e3feb60390012c0105000000000006fffa0090012c010600000000004afcb60390012c010700000001000500050000000000000000000200000000000000000000000000e80319000000190002000000fa0001002800320019001e00fa0000000300000000000100000001000e06000000000000050000000000000000004700430000000000dc054c046c0700000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdcc46f".hexaData
        return nil
    }
}