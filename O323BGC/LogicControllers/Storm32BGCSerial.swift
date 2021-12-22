//
//  Storm32BGC.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation

struct Storm32BGCSerial {
    private let fileDescriptor: Int32

    private let serial = Serial()
    private let x25CRC = X25CRC()
    private let serialQueue = DispatchQueue(label: "Serial Queue")

    init(fileDescriptor: Int32) {
        print("Connecting to fileDescriptor \(fileDescriptor) as serial device")
        self.fileDescriptor = fileDescriptor

    }

    init?(serialDevicePath: String) {
        print("Connecting to \(serialDevicePath) as serial device")
        fileDescriptor = serial.openSerialPort(serialDevicePath)
        if fileDescriptor < 0 {
            print("Failed to open device \(serialDevicePath)")
            return nil
        }
    }

    func close() {
        print("Closing serial connection")
        serial.closeSerialPort(fileDescriptor)
    }

    private func sendCommand(command: String, data: Data? = nil) -> Int {
        guard var toSend = command.data(using: .ascii) else {
            return -1
        }

        if let additionalData = data {
            toSend.append(additionalData)
        }

        var bytesWritten = 0
        toSend.withUnsafeBytes { rawBufferPointer in
            bytesWritten = write(fileDescriptor, rawBufferPointer.baseAddress!, toSend.count)
        }
        if bytesWritten < 0 {
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
            let bytesRead = read(fileDescriptor, bytesPointer, 512)
            if bytesRead < 0 {
                let error = String(utf8String: strerror(errno)) ?? "Unknown error code"
                print("Error reading data: \(error)")
                return nil
            }

            buffer.append(Data(bytes: bytesPointer, count: bytesRead))
        } while (buffer.count < expected)

        let returnChar = String(data: buffer[expected-1...expected-1], encoding: .ascii)
        if returnChar != "o" {
            print("Invalid response, should end with o character. Got '\(returnChar)")
            return nil
        }

        if checkCRC {
            let calculatedChecksum = x25CRC.calculate(data: buffer[0...expected-4])
            let checksum = buffer[expected-3...expected-2].withUnsafeBytes { rawPtr in
                return rawPtr.load(as: UInt16.self)
            }
            
            if checksum != calculatedChecksum {
                print("Csum mismatch \(calculatedChecksum) != \(checksum)")
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

    func getVersion() -> Data? {
        guard fileDescriptor >= 0 else {
            return nil
        }

        if sendCommand(command: "v") < 0 {
            return nil
        }

        guard let buffer = readReponse(length: 57) else {
            return nil
        }

        let dataLength = buffer.count - 3
        return buffer[0...dataLength-1]
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

    func setRawParameters(data: Data) -> Bool {
        guard fileDescriptor > 0 else {
            return false
        }

        var parameterData = data
        let checksum = x25CRC.calculate(data: parameterData)
        withUnsafeBytes(of: checksum) { parameterData.append(contentsOf: $0) }

        guard sendCommand(command: "p", data: parameterData) == parameterData.count + 1 else {
            return false
        }

        guard let response = readReponse(length: 1, checkCRC: false) else {
            return false
        }

        let responseChar = String(data: response, encoding: .ascii)
        return responseChar == "o"
    }

    // my $CMD_s_PARAMETER_ZAHL= 5; #number of values transmitted with a 's' get data command
    func getStatus() -> Data? {
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
            return buffer[0...dataLength-1]
        }
    }

    // my $CMD_d_PARAMETER_ZAHL= 32; #number of values transmitted with a 'd' get data command
    func getData() -> Data? {
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
            return buffer[0...dataLength-1]
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

extension Storm32BGCSerial: Storm32BGC {}
