//
//  BoolToStatusImageTransformer.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 11/12/2020.
//

import Foundation
import Cocoa

class BoolToStatusImageTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSImage.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let boolValue = value as? Bool else { return NSImage(named: "StatusGrey") }
        
        return boolValue ? NSImage(named: "StatusGreen") : NSImage(named: "StatusGrey")
    }
}

extension NSValueTransformerName {
    static let boolToStatusImageTransformerName = NSValueTransformerName(rawValue: "BoolToStatusImageTransformer")
}
