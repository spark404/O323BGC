//
//  Storm32BGC.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation

class Storm32BGC: NSObject {
    private let fileDescriptor: Int32
    private let serial = Serial()
    private let serialQueue = DispatchQueue(label: "Serial Queue")
    
    init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        
        super.init()
    }
    
    private func sendCommand(command: String) -> Int {
        guard let data = command.data(using: .ascii) else {
            return -1
        }
        
        var bytesWritten = 0
        data.withUnsafeBytes { rawBufferPointer in
            bytesWritten = write(fileDescriptor, rawBufferPointer.baseAddress!, data.count)
        }
        if (bytesWritten < 0) {
            let error = String(utf8String: strerror(errno)) ?? "Unknown error code"
            print("Error writing data: \(error)")
            return -1
        }
        
        return bytesWritten
    }
    
    private func readReponse(length: Int, checkCRC: Bool = true) -> Data? {
        let bytesPointer = UnsafeMutableRawPointer.allocate(byteCount: 2048, alignment: 1)
        assert(length < 2048, "Ok, this is way longer than expected")
        
        let expected = length
        var buffer = Data(capacity: 2048)
        repeat {
            let bytesRead = read(fileDescriptor, bytesPointer, 512);
            if (bytesRead < 0) {
                let error = String(utf8String: strerror(errno)) ?? "Unknown error code"
                print("Error reading data: \(error)")
                return nil
            }

            buffer.append(Data(bytes: bytesPointer, count: bytesRead))
        } while (buffer.count < expected)
            
        if (buffer[expected-1] != 0x6f) { // 0x6f = 'o'
            print("Invalid response, should end with o character")
            return nil
        }
        
        if (checkCRC) {
            let x25CRC = X25CRC()
            let calculatedChecksum = x25CRC.calculate(data: buffer[0...expected-4])
            let checksum = buffer[expected-3...expected-2].withUnsafeBytes { rawPtr in
                return rawPtr.load(as: UInt16.self)
            }
            
            if (checksum != calculatedChecksum) {
                print ("Csum mismatch \(calculatedChecksum) != \(checksum)")
                return nil
            }
        }
        
        
        return buffer
    }
    
    private func validateResponse(length: Int = 1) -> Bool {
        if let reponse = readReponse(length: 1, checkCRC: false) {
            return reponse[0] == 0x6f // 'o'
        } else {
            return false
        }
    }
        
    func getVersion() -> Version? {
        guard fileDescriptor > 0 else {
            return nil
        }
        
        if sendCommand(command: "v") < 0 {
            return nil
        }
        
        guard let buffer = readReponse(length: 57) else {
            return nil
        }
        
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
    
    // my $CMD_g_PARAMETER_ZAHL= 125; #number of values transmitted with a 'g' get data command
    // my $SCRIPTSIZE= 128;
    func getRawParameters() -> Data? {
        guard fileDescriptor > 0 else {
            return nil
        }
        
        return serialQueue.sync {
            if sendCommand(command: "g") < 0 {
                return nil
            }

            guard let buffer = readReponse(length: 125 * 2 + 128 + 2 + 1) else {
                return nil
            }

            let dataLength = buffer.count - 3
            return buffer[0...dataLength-1]
        }
    }
        
    // my $CMD_s_PARAMETER_ZAHL= 5; #number of values transmitted with a 's' get data command
    func getStatus() -> Status? {
        guard fileDescriptor > 0 else {
            return nil
        }
        
        return serialQueue.sync {
            if sendCommand(command: "s") < 0 {
                return nil
            }

            guard let buffer = readReponse(length: 5 * 2 + 2 + 1) else {
                return nil
            }

            let dataLength = buffer.count - 3
            return Status(data: buffer[0...dataLength-1])
        }
    }
    
    // my $CMD_d_PARAMETER_ZAHL= 32; #number of values transmitted with a 'd' get data command
    func getData() -> Storm32Data? {
        guard fileDescriptor > 0 else {
            return nil
        }
        
        return serialQueue.sync {
            if sendCommand(command: "d") < 0 {
                return nil
            }

            guard let buffer = readReponse(length: 32 * 2 + 2 + 1) else {
                return nil
            }

            let dataLength = buffer.count - 3
            return Storm32Data(data: buffer[0...dataLength-1])
        }
    }
    
    // send command 'xx'
    // response 'o'
    func resetBoard() {
        guard fileDescriptor > 0 else {
            return
        }
        serialQueue.sync {
            if sendCommand(command: "xx") < 0 {
                print("Failed to send reset")
            }
            
            _ = validateResponse(length: 1)
        }
    }
    
    func calibrateRcTrim() {
        // send command 'RC'
        // response 'o'
    }
    
    func levelGimbal() {
        // send command 'xl'
        // response 'o'
    }
    
    func setToDefault() {
        // send command 'xd'
        // response 'o'
    }
    
    func eraseEeprom() {
        // send command 'xc'
        // reponse 'o'
    }
    
    func retrieveEeprom() {
        // send command 'xr'
        // response 'o'
    }
    
    func storeToEeprom() {
        // send command 'xs'
        // response 'o'
    }
}
