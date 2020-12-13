//
//  WindowController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation
import Cocoa


class MainWindowController: NSWindowController {
    @objc dynamic var serialPorts: [SerialPort] = [SerialPort]()
    @objc dynamic var selection: SerialPort? = nil
    @IBOutlet weak var connectButton: NSButton!
    
    override func windowDidLoad() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onConnect(notification:)), name: .serialConnected, object: nil)
        nc.addObserver(self, selector: #selector(onDisconnect(notification:)), name: .serialDisconnected, object: nil)

        let serial = Serial()
        
        var devices: io_iterator_t = io_iterator_t()
        let kernResult = serial.findDevices(&devices)
        if (kernResult != KERN_SUCCESS) {
            print("Oops")
        }
        
        var device: io_object_t
        repeat {
            device = IOIteratorNext(devices)
            guard let path = serial.getModemPath(device) else {
                continue
            }
            
            let serialPort = SerialPort(path: path)
            serialPorts.append(serialPort)
        } while (device != 0)
        
        serialPorts.append(SerialPort(path: "simulator"))
    }
    
    @IBAction func toggle(sender: Any) {
        guard let button = sender as? NSButton else {
            return
        }
        
        button.isEnabled = false
        if (button.title == "Connect") {
            NotificationCenter.default.post(name: .connectSerial, object: selection)
        } else {
            NotificationCenter.default.post(name: .disconnectSerial, object: selection)
        }
    }
    
    @objc func onConnect(notification: NSNotification) {
        connectButton.title = "Disconnect"
        connectButton.isEnabled = true
    }
    
    @objc func onDisconnect(notification: NSNotification) {
        connectButton.title = "Connect"
        connectButton.isEnabled = true
    }
    
    
}
