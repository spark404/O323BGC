//
//  MenuItemFactory.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation

final class MenuItemFactory {
    func items() -> [MenuItem] {
        return [
            .init(name: "Dashboard"),
            .init(name: "Controls", children: [
                .init(name: "Test")
            ])
        ]
    }
}