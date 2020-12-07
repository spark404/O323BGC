//
//  AppDelegate.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 06/12/2020.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBInspectable @objc dynamic var availablePorts: [SerialPort]?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

