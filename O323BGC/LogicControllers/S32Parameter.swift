//
//  S32Parameter.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 16/12/2020.
//

protocol S32Parameter {
    var name: String { get }
    var type: String { get }
    var position: Int { get }
    var maxValue: Int { get }
    var minValue: Int { get }
    var defaultValue: Int { get }
    var steps: Int { get }
    var integerValue: Int { get }
    var stringValue: String { get }
}

extension S32NumericParameter: S32Parameter {}
extension S32StringParameter: S32Parameter {}
