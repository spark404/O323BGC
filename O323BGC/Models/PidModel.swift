//
//  PidModel.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 16/12/2020.
//

import Cocoa

public class PidModel: NSObject {
    @objc let axis: String
    @objc var pidP: Double
    @objc var pidI: Double
    @objc var pidD: Double
    
    init(axis: String, pidP:Double, pidI:Double, pidD: Double) {
        self.pidP = pidP
        self.pidI = pidI
        self.pidD = pidD
        self.axis = axis
    }
}
