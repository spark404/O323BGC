//
//  AppDelegate.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 06/12/2020.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    override init() {
        super.init()
        ValueTransformer.setValueTransformer(BoolToStatusImageTransformer(), forName: .boolToStatusImageTransformerName)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true;
    }

}

