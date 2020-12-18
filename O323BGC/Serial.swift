//
//  Serial.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 06/12/2020.
//

import Foundation
import IOKit.serial

// swiftlint:disable all

let MATCH_PATH: String? = nil

struct FCNTLOptions: OptionSet {
    let rawValue: CInt
    init(rawValue: CInt) { self.rawValue = rawValue }

    static let  O_RDONLY        = FCNTLOptions(rawValue: 0x0000)
    static let  O_WRONLY        = FCNTLOptions(rawValue: 0x0001)
    static let  O_RDWR          = FCNTLOptions(rawValue: 0x0002)
    static let  O_ACCMODE       = FCNTLOptions(rawValue: 0x0003)
    static let  O_NONBLOCK      = FCNTLOptions(rawValue: 0x0004)
    static let  O_APPEND        = FCNTLOptions(rawValue: 0x0008)
    static let     O_SHLOCK        = FCNTLOptions(rawValue: 0x0010)        /* open with shared file lock */
    static let     O_EXLOCK        = FCNTLOptions(rawValue: 0x0020)        /* open with exclusive file lock */
    static let     O_ASYNC         = FCNTLOptions(rawValue: 0x0040)        /* signal pgrp when data ready */
    // static let     O_FSYNC     = FCNTLOptions(rawValue: O_SYNC         /* source compatibility: do not use */
    static let  O_NOFOLLOW      = FCNTLOptions(rawValue: 0x0100)        /* don't follow symlinks */
    static let     O_CREAT         = FCNTLOptions(rawValue: 0x0200)        /* create if nonexistant */
    static let     O_TRUNC         = FCNTLOptions(rawValue: 0x0400)        /* truncate to zero length */
    static let     O_EXCL          = FCNTLOptions(rawValue: 0x0800)        /* error if already exists */
    static let    O_EVTONLY       = FCNTLOptions(rawValue: 0x8000)        /* descriptor requested for event notifications only */
    
    static let    O_NOCTTY        = FCNTLOptions(rawValue: 0x20000)        /* don't assign controlling terminal */
    static let  O_DIRECTORY     = FCNTLOptions(rawValue: 0x100000)
    static let  O_SYMLINK       = FCNTLOptions(rawValue: 0x200000)      /* allow open of a symlink */
    static let    O_CLOEXEC       = FCNTLOptions(rawValue: 0x1000000)     /* implicitly set FD_CLOEXEC */
    // static let BoxOrBag: PackagingOptions = [Box, Bag]
    // static let BoxOrCartonOrBag: PackagingOptions = [Box, Carton, Bag]
}

class Serial {
    var gOriginalTTYAttrs: termios = termios()

    func findDevices(_ serialPortIterator: inout io_iterator_t) -> kern_return_t {
        var kernResult: kern_return_t = KERN_FAILURE

        let classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue) as NSMutableDictionary
        if classesToMatch.count == 0 {
            return kernResult
        }

        classesToMatch[kIOSerialBSDTypeKey] = kIOSerialBSDRS232Type // kIOSerialBSDRS232Type

        kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &serialPortIterator)
        if kernResult != KERN_SUCCESS {
            print("IOServiceGetMatchingServices returned \(kernResult)")
            return kernResult
        }

        return kernResult
    }

    func selectModemPath(_ serialPortIterator: io_iterator_t) -> String? {
        var modemService: io_object_t
        var modemFound = false
        var bsdPath: String? = nil

        // Iterate across all modems found. Use the last one
        repeat {
            modemService = IOIteratorNext(serialPortIterator)
            guard modemService != 0 else { continue }

            if let aPath = IORegistryEntryCreateCFProperty(modemService,
                                                           "IOCalloutDevice" as CFString,
                                                           kCFAllocatorDefault, 0).takeUnretainedValue() as? String {
                bsdPath = aPath
                if (aPath == MATCH_PATH) {
                    modemFound = true
                }
            }

        } while (modemService != 0 && !modemFound)

        return bsdPath
    }

    func getModemPath(_ device: io_object_t) -> String? {
        guard device != 0 else {
            return nil
        }

        if let aPath = IORegistryEntryCreateCFProperty(device,
                                                       "IOCalloutDevice" as CFString,
                                                       kCFAllocatorDefault, 0).takeUnretainedValue() as? String {
            return aPath
        }

        return nil
    }

    func openSerialPort(_ bsdPath: String) -> Int32 {
        // var fileDescriptor: Int = -1
        var options: termios

        // Open the serial port read/write, with no controlling terminal, and don't wait for a connection.
        // The O_NONBLOCK flag also causes subsequent I/O on the device to be non-blocking.
        // See open(2) <x-man-page://2/open> for details.

        let openOptions: FCNTLOptions = [.O_RDWR, .O_NOCTTY, .O_NONBLOCK]
        let fileDescriptor = open(bsdPath, openOptions.rawValue);
        if (fileDescriptor < 0) {
            let error = String(utf8String: strerror(errno)) ?? "Unknown error code"
            print("Error opening port: \(error)")
            return fileDescriptor
        }

        // Note that open() follows POSIX semantics: multiple open() calls to the same file will succeed
        // unless the TIOCEXCL ioctl is issued. This will prevent additional opens except by root-owned
        // processes.
        // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.

        var result = ioctl(fileDescriptor, TIOCEXCL)
        if result == -1 {
            let error = String(utf8String: strerror(errno)) ?? "Unknown error code"
            print("Error setting TIOCEXCL: \(error)")
            return fileDescriptor
        }

        // Now that the device is open, clear the O_NONBLOCK flag so subsequent I/O will block.
        // See fcntl(2) <x-man-page//2/fcntl> for details.

        result = fcntl(fileDescriptor, F_SETFL, 0)
        if result == -1 {
            let error = String(utf8String: strerror(errno)) ?? "Unknown error code"
            print("Error clearing O_NONBLOCK: \(error)")
            return fileDescriptor
        }

        // Get the current options and save them so we can restore the default settings later.
        result = tcgetattr(fileDescriptor, &gOriginalTTYAttrs)
        if result == -1 {
            print("Error getting attributes \(bsdPath) - \(strerror(errno))(\(errno))")
        }

        // The serial port attributes such as timeouts and baud rate are set by modifying the termios
        // structure and then calling tcsetattr() to cause the changes to take effect. Note that the
        // changes will not become effective without the tcsetattr() call.
        // See tcsetattr(4) <x-man-page://4/tcsetattr> for details.

        options = gOriginalTTYAttrs;

        // Print the current input and output baud rates.
        // See tcsetattr(4) <x-man-page://4/tcsetattr> for details.

        print("Current input baud rate is \(cfgetispeed(&options))")
        print("Current output baud rate is \(cfgetospeed(&options))")

        // Set raw input (non-canonical) mode, with reads blocking until either a single character
        // has been received or a one second timeout expires.
        // See tcsetattr(4) <x-man-page://4/tcsetattr> and termios(4) <x-man-page://4/termios> for details.

        cfmakeraw(&options)
        // options.c_cc[VMIN] = 0
        // options.c_cc[VTIME] = 10;

        // The baud rate, word length, and handshake options can be set as follows:

        cfsetspeed(&options, 115200);            // Set 115200 baud
        options.c_cflag |= UInt(CS8          |   // Set 8N1
                                CLOCAL)          // No modem control

        // The IOSSIOSPEED ioctl can be used to set arbitrary baud rates
        // other than those specified by POSIX. The driver for the underlying serial hardware
        // ultimately determines which baud rates can be used. This ioctl sets both the input
        // and output speed.

        // let speed: speed_t = 2400; // Set 14400 baud
        // result = ioctlIOSSIOSPEED(fileDescriptor, UnsafeMutablePointer(bitPattern: speed))
        // result = ioctl(fileDescriptor, IOSSIOSPEED, 2400)
        // if (result == -1) {
        // printf("Error calling ioctl(..., IOSSIOSPEED, ...) %s - %s(%d).\n" bsdPath, strerror(errno), errno);
        //    print("Error calling ioctl(..., IOSSIOSPEED, ...) \(strerror(errno)) \(errno)")
        // }

        // Print the new input and output baud rates. Note that the IOSSIOSPEED ioctl interacts with the serial driver
        // directly bypassing the termios struct. This means that the following two calls will not be able to read
        // the current baud rate if the IOSSIOSPEED ioctl was used but will instead return the speed set by the last call
        // to cfsetspeed.

        print("Input baud rate changed to \(cfgetispeed(&options))")
        print("Output baud rate changed to \(cfgetospeed(&options))")

        // Cause the new options to take effect immediately.
        if (tcsetattr(fileDescriptor, TCSANOW, &options) == -1) {
            print("Error setting attributes")
        }

        // To set the modem handshake lines, use the following ioctls.
        // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.
        // Assert Data Terminal Ready (DTR)
        if(ioctl(fileDescriptor, TIOCSDTR) == -1) {
            print("Error asserting DTR \(bsdPath) - \(strerror(errno))(\(errno)).")
        }

        // Clear Data Terminal Ready (DTR)
        if(ioctl(fileDescriptor, TIOCCDTR) == -1) {
            print("Error clearing DTR \(bsdPath) - \(strerror(errno))(\(errno))")
        }

        // Set the modem lines depending on the bits set in handshake
        var handshake = TIOCM_DTR | TIOCM_RTS | TIOCM_CTS | TIOCM_DSR
        if(ioctl(fileDescriptor, TIOCMSET, &handshake) == -1) {
            print("Error setting handshake lines \(bsdPath) - \(strerror(errno))(\(errno))")
        }

        // To read the state of the modem lines, use the following ioctl.
        // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.
        // Store the state of the modem lines in handshake
        if(ioctl(fileDescriptor, TIOCMGET, &handshake) == -1){
            print("Error getting handshake lines \(bsdPath) - \(strerror(errno))(\(errno))")
        }
        print("Handshake lines currently set to \(handshake)")

        /*
         // Set the receive latency in microseconds. Serial drivers use this value to determine how often to
         // dequeue characters received by the hardware. Most applications don't need to set this value: if an
         // app reads lines of characters, the app can't do anything until the line termination character has been
         // received anyway. The most common applications which are sensitive to read latency are MIDI and IrDA
         // applications.
         var mics = 1
         
         if(ioctl(fileDescriptor, IOSSDATALAT, &mics) == -1) {
         // set latency to 1 microsecond
         print("Error setting read latency \(bsdPath) - \(strerror(errno))(\(errno))")
         //goto error
         }
         */
        // Success
        return fileDescriptor
    }

    func closeSerialPort(_ port: Int32) {
        close(Int32(port))
    }

}
