//
//  Storm32BGC.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 20/12/2020.
//

import Foundation

protocol Storm32BGC {
    func getVersion() -> Version?
    func getStatus() -> Status?
    func getData() -> Storm32Data?
    func getRawParameters() -> Data?
    func setRawParameters(data: Data) -> Bool
    func resetBoard()
    func close()
}
