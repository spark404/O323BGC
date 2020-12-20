//
//  DataLoaders.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 20/12/2020.
//

import Foundation

struct VersionLoader {
    static func load(data: Data) -> Version {
        let version = String(bytes: data[0...15].prefix(while: { $0 != 0x0}), encoding: .ascii)!
        let name =  String(bytes: data[16...31].prefix(while: { $0 != 0x0}), encoding: .ascii)!
        let board =  String(bytes: data[32...47].prefix(while: { $0 != 0x0}), encoding: .ascii)!
        let versionNumber = data[48...49].withUnsafeBytes { rawPtr in
            return rawPtr.load(as: UInt16.self)
        }
        let layout = data[50...51].withUnsafeBytes { rawPtr in
            return rawPtr.load(as: UInt16.self)
        }
        let capabilities = data[52...53].withUnsafeBytes { rawPtr in
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
}

struct StatusLoader {
    static func load(data: Data) -> Status {
        let values = data.withUnsafeBytes {
            [UInt16](UnsafeBufferPointer(start: $0, count: data.count / 2 ))
        }
        return Status(values: values)
    }
}

struct DataLoader {
    static func load(data: Data) -> Storm32Data {
        let values = data.withUnsafeBytes {
            [UInt16](UnsafeBufferPointer(start: $0, count: data.count / 2 ))
        }

        return Storm32Data(values: values)
    }
}

extension Data {
    func decodeToVersion() -> Version {
        return VersionLoader.load(data: self)
    }

    func decodeToStatus() -> Status {
        return StatusLoader.load(data: self)
    }

    func decodeToData() -> Storm32Data {
        return DataLoader.load(data: self)
    }
}
