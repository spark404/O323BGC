//
//  MenuViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation
import Cocoa

class MenuViewController: NSViewController {
    
    @objc dynamic var menuStructure = [MenuItem]()
    var fileDescriptor: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuStructure.append(contentsOf: MenuItemFactory().items())
    
        NotificationCenter.default.addObserver(self, selector: #selector(connectSerial), name: .connectSerial, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectSerial), name: .disconnectSerial, object: nil)
    }
    
    override func viewDidDisappear() {
        if (fileDescriptor != -1) {
            Serial().closeSerialPort(fileDescriptor)
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func connectSerial(message: NSNotification) {
        print("Entering connectSerial, \(message)")
        guard let path = message.object as? String else {
            print ("Received connect notification without path")
            NotificationCenter.default.post(name: .serialDisconnected, object: nil)
            return
        }
        
        let serial = Serial()
        fileDescriptor = serial.openSerialPort(path)
        if (fileDescriptor == -1 ) {
            print("Failed to open serial port")
            NotificationCenter.default.post(name: .serialDisconnected, object: nil)
            return
        }
        
        print("Serial connected, fd \(fileDescriptor)")
        
        NotificationCenter.default.post(name: .serialConnected, object: nil)
    }
    
    @objc func disconnectSerial(message: NSNotification) {
        print("Entering disconnectSerial")
        guard fileDescriptor != -1 else {
            print ("Received disconnect notification without connection")
            NotificationCenter.default.post(name: .serialDisconnected, object: nil)
            return
        }
        
        let serial = Serial()
        serial.closeSerialPort(fileDescriptor)
        print("Serial disconnected, fd was \(fileDescriptor)")
        fileDescriptor = -1
        
        NotificationCenter.default.post(name: .serialDisconnected, object: nil)
    }
    
}

extension MenuViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("HeaderCell"), owner: self)
    }
    
}
