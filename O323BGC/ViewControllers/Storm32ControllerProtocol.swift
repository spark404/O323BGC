//
//  Storm32ControllerProtocol.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 18/12/2020.
//

import Foundation

protocol Storm32ControllerProtocol {
    var storm32BGCController: Storm32BGCController? { get set }
}

extension DashboardViewController: Storm32ControllerProtocol {}
extension MenuViewController: Storm32ControllerProtocol {}
extension MainTabViewController: Storm32ControllerProtocol {}
extension RealtimeViewController: Storm32ControllerProtocol {}
extension RcInputParameterViewControler: Storm32ControllerProtocol {}
extension MotorParameterViewController: Storm32ControllerProtocol {}
