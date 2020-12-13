//
//  ControllerModel.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 09/12/2020.
//

import Foundation

@objc public class ControllerModel: NSObject {
    @objc let version: Version
    @objc let status: Status
    
    init(version: Version, status: Status) {
        self.version = version
        self.status = status
        
        super.init()
    }
}
