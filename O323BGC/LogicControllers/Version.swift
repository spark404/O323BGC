//
//  Version.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation

@objc public class Version: NSObject {
    @objc let version: String
    @objc let versionNumber: UInt16
    @objc let name: String
    @objc let board: String
    @objc let layout: UInt16
    @objc let capabilities: UInt16
    
    init(version: String, versionNumber: UInt16, name: String, board: String, layout: UInt16, capabilities: UInt16) {
        self.version = version
        self.name =  name
        self.board = board
        self.versionNumber = versionNumber
        self.layout = layout
        self.capabilities = capabilities
    }
}
