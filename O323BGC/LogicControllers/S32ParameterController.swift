//
//  S32ParameterController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 16/12/2020.
//

import Foundation

struct S32ParameterController {
    private let storm32BGC: Storm32BGC
    private let referenceData: [String: AnyObject]
    
    init(storm32BGC: Storm32BGC) {
        self.storm32BGC = storm32BGC
        
        guard let referenceData = S32ParameterController.loadParameterReferenceData() else {
            fatalError("Failed to load parameter reference data")
        }
        self.referenceData = referenceData
    }
    
    func retrieveParameters() -> [S32Parameter]? {
        guard let parameters = loadParametersFromDevice() else {
            return nil
        }
        
        return parameters.compactMap {
            return $0.value
        }
    }
    
    func retrieveParameterByName(_ name: String) -> S32Parameter? {
        guard let parameters = loadParametersFromDevice() else {
            return nil
        }

        return parameters[name]
    }

    func storeParameter(parameter: S32Parameter, new value: Int) -> Bool {
        guard var rawData = storm32BGC.getRawParameters() else {
            return false
        }

        let byteIndex = parameter.position * 2
        rawData[byteIndex...byteIndex+1].withUnsafeMutableBytes { rawPtr in
            rawPtr.storeBytes(of: UInt16(value), toByteOffset: 0, as: UInt16.self)
        }

        return storm32BGC.setRawParameters(data: rawData)
    }

    private func loadParametersFromDevice() -> [String: S32Parameter]? {
        guard let rawData = storm32BGC.getRawParameters() else {
            return nil
        }

        let results: [String: S32Parameter] = referenceData.mapValues {
            guard let reference = $0 as? [String: Any] else {
                fatalError("Issue with parameter reference data")
            }
            return mergeReferenceAndValueData(reference: reference, rawData: rawData)!
        }
        
        return results
    }

    private func mergeReferenceAndValueData(reference: [String: Any], rawData: Data) -> S32Parameter? {
        guard let name = reference["Name"] as? String,
              let position = reference["Position"] as? Int,
              let type = reference["Type"] as? String,
              let minValue = reference["MinValue"] as? Int,
              let maxValue = reference["MaxValue"] as? Int,
              let defaultValue = reference["DefaultValue"] as? Int,
              let steps = reference["Steps"] as? Int
        else {
            return nil
        }

        let byteIndex = position * 2
        switch type {
        case "UInt16":
            let value = rawData[byteIndex...byteIndex+1].withUnsafeBytes { rawPtr in
                return rawPtr.load(as: UInt16.self)
            }
            return S32NumericParameter(
                name: name,
                type: type,
                position: position,
                maxValue: maxValue,
                minValue: minValue,
                defaultValue: defaultValue,
                steps: steps,
                integerValue: Int(value))
        case "Int16":
            let value = rawData[byteIndex...byteIndex+1].withUnsafeBytes { rawPtr in
                return rawPtr.load(as: Int16.self)
            }
            return S32NumericParameter(
                name: name,
                type: type,
                position: position,
                maxValue: maxValue,
                minValue: minValue,
                defaultValue: defaultValue,
                steps: steps,
                integerValue: Int(value))
        case "OptionList":
            let value = rawData[byteIndex]
            guard let optionList = reference["Options"] as? [String] else { return nil }
            return S32StringParameter(
                name: name,
                type: type,
                position: position,
                maxValue: maxValue,
                minValue: minValue,
                defaultValue: defaultValue,
                steps: steps,
                integerValue: Int(value),
                optionList: optionList)
        default:
            return nil
        }
    }

    private static func loadParameterReferenceData() -> [String: AnyObject]? {
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
        let plistPath: String? = Bundle.main.path(forResource: "parameters", ofType: "plist")!
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        do {
            let propertyList = try PropertyListSerialization
                .propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat)
            guard let plistData = propertyList as? [String: AnyObject]  else { return nil }
            return plistData
        } catch {
            print("Error reading plist: \(error), format: \(propertyListFormat)")
            return nil
        }
    }
}
