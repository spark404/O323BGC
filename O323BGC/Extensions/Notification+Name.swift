//
//  Notification+Name.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation

extension Notification.Name {
    static let connectSerial = Notification.Name("connectSerial")
    static let disconnectSerial = Notification.Name("disconnectSerial")
    static let serialConnected = Notification.Name("serialConnected")
    static let serialDisconnected = Notification.Name("serialDisconnected")
    static let requestControllerReset = Notification.Name("requestControllerReset")
    
    static let startRealtimeData = Notification.Name("startRealtimeData")
    static let stopRealtimeData = Notification.Name("stopRealtimeData")
    static let updateRealtimeData = Notification.Name("updateRealtimeData")
}
