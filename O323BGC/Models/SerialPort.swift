//
//  SerialPort.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation

@objc class SerialPort: NSObject {
    @objc dynamic var path: String
    
    init(path: String) {
        self.path = path
    }
}
