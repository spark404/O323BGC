//
//  MenuItem.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation

@objc public class MenuItem: NSObject {
    @objc let name: String
    @objc let children: [MenuItem]
    @objc let selectable: Bool
    
    init(name: String, children: [MenuItem] = [], selectable: Bool = true) {
        self.name = name
        self.children = children
        self.selectable = selectable
    }
}
