//
//  Data.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 11/12/2020.
//

import Foundation

public enum Storm32DataIndex: Int {
    // First five words are equal to the status object
    // ((u16*)fbuf)[(*len)++]= STATE; //state
    case state

    // ((u16*)fbuf)[(*len)++]= status; //status
    case status

    // ((u16*)fbuf)[(*len)++]= status2; //status2
    case status2

    // ((u16*)fbuf)[(*len)++]= i2c_geterrorcntofdevice(IMU_I2CDEVNR)+i2c_geterrorcntofdevice(IMU2_I2CDEVNR);
    case error

    // ((u16*)fbuf)[(*len)++]= adc_lipovoltage(); //lipo_voltage;
    case voltage

    // ((u16*)fbuf)[(*len)++]= (u16)systicks; //timestamp
    case millis

    // ((u16*)fbuf)[(*len)++]= (u16)(1.0E6*fdT); //cycle time
    case cycleTime

    // ((u16*)fbuf)[(*len)++]= (s16)(fImu1.imu.gx);
    case imuGx

    // ((u16*)fbuf)[(*len)++]= (s16)(fImu1.imu.gy);
    case imuGy

    // ((u16*)fbuf)[(*len)++]= (s16)(fImu1.imu.gz);
    case imuGz

    // ((u16*)fbuf)[(*len)++]= (s16)(10000.0f*fImu1.imu.ax);
    case imu1ImuAx

    // ((u16*)fbuf)[(*len)++]= (s16)(10000.0f*fImu1.imu.ay);
    case imu1ImuAy

    // ((u16*)fbuf)[(*len)++]= (s16)(10000.0f*fImu1.imu.az);
    case imu1ImuAz

    // ((u16*)fbuf)[(*len)++]= (s16)(10000.0f*fImu1AHRS.R.x);
    case imu1AhrsRx

    // ((u16*)fbuf)[(*len)++]= (s16)(10000.0f*fImu1AHRS.R.y);
    case imu1AhrsRy

    // ((u16*)fbuf)[(*len)++]= (s16)(10000.0f*fImu1AHRS.R.z);
    case imu1AhrsRz

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*fImu1Angle.Pitch);
    case imu1AnglePitch

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*fImu1Angle.Roll);
    case imu1AngleRoll

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*fImu1Angle.Yaw);
    case imu1AngleYaw

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*cPID[PITCH].Cntrl);
    case cPIDPitchCntrl

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*cPID[ROLL].Cntrl);
    case cPIDRollCntrl

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*cPID[YAW].Cntrl);
    case cPIDYawCntrl

    // ((u16*)fbuf)[(*len)++]= InputSrc.Pitch;
    case inputSrcPitch

    // ((u16*)fbuf)[(*len)++]= InputSrc.Roll;
    case inputSrcRoll

    // ((u16*)fbuf)[(*len)++]= InputSrc.Yaw;
    case inputSrcYaw

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*fImu2Angle.Pitch);
    case imu2AnglePitch

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*fImu2Angle.Roll);
    case imu2AngleRoll

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*fImu2Angle.Yaw);
    case imu2AngleYaw

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*fMag2Angle.Yaw);
    case mag2AngleYaw

    // ((u16*)fbuf)[(*len)++]= (s16)(100.0f*fMag2Angle.Pitch);
    case mag2AnglePitch

    // ((u16*)fbuf)[(*len)++]= (s16)(10000.0f*fImu1AHRS._imu_acc_confidence);
    case accConfidence

    // ((u16*)fbuf)[(*len)++] = pack_functioninputvalues(&FunctionInputPulse);
    case functionInputPulse
}

public class Storm32Data: NSObject {
    var values: [UInt16]

    public init(values: [UInt16]) {
        self.values = values
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
        if index.rawValue >= 0 && index.rawValue <= 6 || index == .accConfidence {
            // These values are unsigned
            return Float(getUInt16ValueFor(index: index))
        } else {
            return Float(getInt16ValueFor(index: index))
        }
    }
}
