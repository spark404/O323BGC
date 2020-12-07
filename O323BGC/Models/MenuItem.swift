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
    
    init(name: String, children: [MenuItem] = []) {
        self.name = name
        self.children = children
    }
}
