//
//  Storm32BGCController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 10/12/2020.
//

import Foundation

class Storm32BGCController: NSObject {
    private var serial = Serial()
    
    private var fileDescriptor: Int32
    private var storm32BGC: Storm32BGC
    
    private var statusTimer: Timer?
    private var serialQueue = DispatchQueue(label: "Serial Queue")
    
    private var realTimeTimer: Timer?
    private var realTimeRecipient: Storm32BGCRealtimeData?
    
    var delegate: Storm32BGCStatusDelegate?
    var status: Status?
    var version: Version?
    
    init?(devicePath: String) {
        print ("Opening device \(devicePath) as serial device")
        self.fileDescriptor = serial.openSerialPort(devicePath)
        if (fileDescriptor < 0) {
            print ("Failed to open device \(devicePath)")
            return nil
        }
        
        print ("Validating connection to Stomr32BGC device")
        storm32BGC = Storm32BGC(fileDescriptor: fileDescriptor)
        version = storm32BGC.getVersion()
        if (version?.versionNumber != 96) {
            print("No device or no matching version")
            serial.closeSerialPort(fileDescriptor)
            return nil
        }
        
        print ("Connected to board \(version!.name) with version \(version!.version)")
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetDevice), name: .requestControllerReset, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startRealtimeUpdates), name: .startRealtimeData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopRealtimeUpdates), name: .stopRealtimeData, object: nil)

        // getStatus takes between 1 and 8 milliseconds to complete
        statusTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(retrieveStatusFromDevice), userInfo: nil, repeats: true)
    }
    
    func disconnect() {
        serialQueue.sync {
            self.realTimeTimer?.invalidate()
            self.realTimeTimer = nil
            
            self.statusTimer?.invalidate()
            self.statusTimer = nil
        
            if (self.fileDescriptor > -1) {
                self.serial.closeSerialPort(self.fileDescriptor)
                self.fileDescriptor = -1
            }
        }
    }
    
    @objc func retrieveStatusFromDevice() {
        self.status = serialQueue.sync {
             self.storm32BGC.getStatus()
        }
        delegate?.didUpdateStatus(self)
    }
    
    @objc func retrieveDataFromDevice() {
        serialQueue.sync {
            self.storm32BGC.getData()
        }
    }
    
    @objc func resetDevice() {
        print("Executing reset on device")
        serialQueue.sync {
            self.storm32BGC.resetBoard()
        }
    }
    
    @objc func startRealtimeUpdates(message: NSNotification) {
        print ("Starting realtime updates")
        guard realTimeTimer == nil else {
            print("Realtime timer already exists")
            return
        }
        
        guard let recipient = message.object as? Storm32BGCRealtimeData else {
            print("Recipient doesn't implement Storm32BGCRealtimeData")
            return
        }
        
        realTimeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard let data = self.storm32BGC.getData() else {
                return
            }
            recipient.updateData(data: data)
        }
    }
    
    @objc func stopRealtimeUpdates(message: NSNotification) {
        print ("Stopping realtime updates")
        realTimeTimer?.invalidate()
        realTimeTimer = nil
    }
    
}

protocol Storm32BGCRealtimeData {
    func updateData(data: Storm32Data)
}
