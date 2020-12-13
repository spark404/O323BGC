//
//  Status.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 09/12/2020.
//

import Foundation

// Bit fields for the status value
// Counted from the rightmost bit as 0
enum StatusBit: Int {
    case storm32LinkInUse
    case storm32LinkOk
    case levelFailed
    case batConnected
    case batVoltageIsLow
    case imuOk
    case imu2Ok
    case magOk
    case storm32LinkPresent
    case ntBusInUse
    case imu2NTBus
    case imu2HighAdr
    case imu2Present
    case magPresent
    case imuHighAdr
    case imuPresent
}

enum Status2Bit: Int {
    case panYaw           = 15
    case panRoll          = 14
    case panPitch         = 13
    case standby          = 12
    case irCamera         = 11
    case recenterYaw      = 10
    case recenterRoll     =  9
    case recenterPitch    =  8
    case motorYawActive   =  5
    case motorRollActive  =  4
    case motorPitchActive =  3
}

enum State: Int {
    case STARTUP_MOTORS             = 0;
    case STARTUP_SETTLE             = 1;
    case STARTUP_CALIBRATE          = 2;
    case STARTUP_LEVEL              = 3;
    case STARTUP_MOTORDIRDETECT     = 4;
    case STARTUP_RELEVEL            = 5;
    case NORMAL                     = 6;
    case STANDBY                    = 7;

}

@objc public class Status: NSObject {
    @objc var isIMUPresent: Bool {
        get {
            return getStatusBit(.imuPresent)
        }
    }
    
    @objc var isIMUOk: Bool {
        get {
            return getStatusBit(.imuOk)
        }
    }
    
    @objc var isIMUHighAdr: Bool {
        get {
            return getStatusBit(.imuHighAdr)
        }
    }
    
    @objc var isIMU2Present: Bool {
        get {
            return getStatusBit(.imu2Present)
        }
    }
    
    @objc var isIMU2Ok: Bool {
        get {
            return getStatusBit(.imu2Ok)
        }
    }
    
    @objc var isIMU2HighAdr: Bool {
        get {
            return getStatusBit(.imu2HighAdr)
        }
    }

    @objc var isIMU2NTBus: Bool {
        get {
            return getStatusBit(.imu2NTBus)
        }
    }
    
    @objc var isNTBusInUse: Bool {
        get {
            return getStatusBit(.ntBusInUse)
        }
    }

    @objc var isMAGPresent: Bool {
        get {
            return getStatusBit(.magPresent)
        }
    }
    
    @objc var isMAGOk: Bool {
        get {
            return getStatusBit(.magOk)
        }
    }
    
    @objc var isStorm32LinkPresent: Bool {
        get {
            return getStatusBit(.storm32LinkPresent)
        }
    }

    @objc var isStorm32LinkOk: Bool {
        get {
            return getStatusBit(.storm32LinkOk)
        }
    }

    @objc var isStorm32LinkInUse: Bool {
        get {
            return getStatusBit(.storm32LinkInUse)
        }
    }
    
    @objc var isLevelFailed: Bool {
        get {
            return getStatusBit(.levelFailed)
        }
    }

    @objc var isBatConnected: Bool {
        get {
            return getStatusBit(.batConnected)
        }
    }
    
    @objc var isBatVoltageIsLow: Bool {
        get {
            return getStatusBit(.batVoltageIsLow)
        }
    }
    
    @objc var isYawMotorActive: Bool {
        get {
            return getStatus2Bit(.motorYawActive)
        }
    }

    @objc var isRollMotorActive: Bool {
        get {
            return getStatus2Bit(.motorRollActive)
        }
    }

    @objc var isPitchMotorActive: Bool {
        get {
            return getStatus2Bit(.motorPitchActive)
        }
    }

    @objc var isPanYaw: Bool {
        get {
            return getStatus2Bit(.panYaw)
        }
    }

    @objc var isPanRoll: Bool {
        get {
            return getStatus2Bit(.panRoll)
        }
    }

    @objc var isPanPitch: Bool {
        get {
            return getStatus2Bit(.panPitch)
        }
    }
    
    @objc var isRecenterYaw: Bool {
        get {
            return getStatus2Bit(.recenterYaw)
        }
    }

    @objc var isRecenterRoll: Bool {
        get {
            return getStatus2Bit(.recenterRoll)
        }
    }

    @objc var isRecenterPitch: Bool {
        get {
            return getStatus2Bit(.recenterPitch)
        }
    }
    
    @objc var errors: Int {
        return Int(values[3])
    }
    
    @objc var voltage: Float {
        return Float(values[4]) / 1000
    }

    @objc var state: String {
        get {
            if let value = State(rawValue: Int(values[0])) {
                switch value {
                case .NORMAL:
                    return "Normal"
                case .STANDBY:
                    return "Standby"
                case .STARTUP_CALIBRATE:
                    return "Startup - Calibrate"
                case .STARTUP_MOTORS:
                    return "Startup - Motors"
                case .STARTUP_SETTLE:
                    return "Startup - Settle"
                case .STARTUP_LEVEL:
                    return "Startup - Level"
                case .STARTUP_MOTORDIRDETECT:
                    return "Startup - MotorDirDetect"
                case .STARTUP_RELEVEL:
                    return "Startup - Relevel"
                }
            } else {
                return "Unknown"
            }
        }
    }
    
    private let values: [UInt16]
    
    public init?(data: Data) {
        guard data.count == 5 * 2 else {
            print("Expected \(5*2) bytes, got \(data.count)")
            return nil
        }
        
        values = data.withUnsafeBytes {
            [UInt16](UnsafeBufferPointer(start: $0, count: data.count / 2 ))
        }
    }
    
    private func getStatusBit(_ field: StatusBit) -> Bool {
        return values[1].bit(field.rawValue)
    }

    private func getStatus2Bit(_ field: Status2Bit) -> Bool {
        return values[2].bit(field.rawValue)
    }
}
