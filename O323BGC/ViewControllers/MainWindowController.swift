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
    @objc dynamic var selection: String?
    
    // Toolbar outlets
    @IBOutlet weak var connectButton: NSButton!

    private var storm32Controller: Storm32BGCController
    
    init() {
        storm32Controller = Storm32BGCController()
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        storm32Controller = Storm32BGCController()
        super.init(coder: coder)
    }

    override func windowDidLoad() {
        let serial = Serial()

        var devices: io_iterator_t = io_iterator_t()
        let kernResult = serial.findDevices(&devices)
        if kernResult != KERN_SUCCESS {
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

        // Inject the Storm32BGCController
        print("Initial inject")
        guard let mainController = contentViewController as? MainSplitViewController else {
            fatalError("Something horribly wrong here")
        }
        mainController.storm32Controller = storm32Controller
    }

    @IBAction func toggle(sender: Any) {
        guard let button = sender as? NSButton else {
            return
        }

        button.isEnabled = false
        if button.title == "Connect" {
            guard let selectedPort = selection else {
                return
            }

            guard !storm32Controller.connected else {
                return
            }

            if storm32Controller.connect(devicePath: selectedPort) {
                connectButton.title = "Disconnect"
                connectButton.isEnabled = true
            } else {
                connectButton.title = "Connect"
                connectButton.isEnabled = true
            }

        } else {
            storm32Controller.disconnect()
            
            connectButton.title = "Connect"
            connectButton.isEnabled = true
        }
    }
}
