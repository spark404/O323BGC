//
//  Storm32BGC.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 20/12/2020.
//

import Foundation

protocol Storm32BGC {
    func getVersion() -> Data?
    func getStatus() -> Data?
    func getData() -> Data?
    func getRawParameters() -> Data?
    func setRawParameters(data: Data) -> Bool
    func resetBoard()
    func close()
}
