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
            .init(name: "Dataview"),
            .init(
                name: "Parameters",
                children: [
                .init(name: "PID"),
                .init(name: "All Parameters")
                ],
                selectable: false
            )
        ]
    }
}
