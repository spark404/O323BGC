//
//  S32StringParameter.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 16/12/2020.
//

struct S32StringParameter {
    let name: String
    let type: String
    let position: Int
    let maxValue: Int
    let minValue: Int
    let defaultValue: Int
    let steps: Int
    let integerValue: Int
    let optionList: [String]
    var stringValue: String {
        get {
            if integerValue < 0 || integerValue >= optionList.count  {
                return "Unknown \(integerValue)"
            }
            return optionList[integerValue]
        }
    }
}
