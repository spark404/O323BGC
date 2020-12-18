//
//  S32NumericParameter.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 16/12/2020.
//

struct S32NumericParameter {
    let name: String
    let type: String
    let position: Int
    let maxValue: Int
    let minValue: Int
    let defaultValue: Int
    let steps: Int
    let integerValue: Int
    var stringValue: String {
        get {
            switch (type) {
            default:
                return "\(integerValue)"
            }
        }
    }
}
