//
//  Extension+S32ParameterArray.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 18/12/2020.
//

import Foundation

extension Array where Element == S32Parameter {
    func findBy(name: String) -> S32Parameter? {
        let firstIndex = self.firstIndex {
            return $0.name == name
        }
        if let index = firstIndex {
            return self[index]
        } else {
            return nil
        }
    }
}
