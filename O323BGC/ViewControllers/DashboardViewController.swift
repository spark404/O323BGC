//
//  DashboardViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 08/12/2020.
//

import Foundation
import Cocoa

class DashboardViewController: NSViewController {
    @IBOutlet weak var versionField: NSTextField!
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var boardField: NSTextField!
    
    @IBOutlet weak var imuStatus: StatusView!
    @IBOutlet weak var imu2Status: StatusView!
    @IBOutlet weak var magStatus: StatusView!
    @IBOutlet weak var batStatus: StatusView!
    @IBOutlet weak var stateField: NSTextFieldCell!
    @IBOutlet weak var stLinkStatus: StatusView!
    
    @IBOutlet weak var axisDashboard: NSView!
    @IBOutlet weak var voltageTextField: NSTextField!
    @IBOutlet weak var errorsTextField: NSTextField!
    @IBOutlet weak var resetButton: NSButton!

    var axisDashboardViewControler: AxisDashboardViewController?

    override func viewDidLoad() {
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            if let viewController = axisDashboardViewControler {
                viewController.representedObject = representedObject
            }

            guard let controllerModel = representedObject as? ControllerModel else {
                imuStatus.present = false
                imuStatus.statusText = ""
                imu2Status.present = false
                imu2Status.statusText = ""
                magStatus.present = false
                magStatus.statusText = ""
                batStatus.present = false
                batStatus.statusText = ""
                
                errorsTextField.stringValue = "Errors: --"
                voltageTextField.stringValue = "Voltage: --"
                
                resetButton.isEnabled = false
                return
            }
            
            let status = controllerModel.status

            resetButton.isEnabled = true
            
            imuStatus.present = status.isIMUPresent
            imuStatus.status = status.isIMUOk
            imuStatus.statusText = status.isIMUOk ? "OK" : ""
            if status.isIMUPresent && status.isIMUHighAdr {
                imuStatus.statusText += "@HighAdr"
            }

            imu2Status.present = status.isIMU2Present
            imu2Status.status = status.isIMU2Ok
            imu2Status.statusText = status.isIMU2Ok ? "OK" : ""
            if status.isIMU2Present && status.isIMU2HighAdr {
                imu2Status.statusText += "@HighAdr "
            }
            if status.isIMU2Present && status.isIMU2NTBus {
                imu2Status.statusText += "@NTBus "
                if status.isNTBusInUse {
                    imu2Status.statusText += "(in Use)"
                }
            }

            magStatus.present = status.isMAGPresent
            magStatus.status = status.isMAGOk
            magStatus.statusText = status.isMAGPresent && status.isIMUOk ? "OK" : ""

            batStatus.present = status.isBatConnected
            batStatus.status = !status.isBatVoltageIsLow
            batStatus.statusText = status.isBatConnected && status.isBatVoltageIsLow ? "Low voltage" : ""

            stLinkStatus.present = status.isStorm32LinkPresent
            stLinkStatus.status = status.isStorm32LinkOk
            stLinkStatus.statusText = status.isStorm32LinkInUse ? "Link in Use" : ""

            voltageTextField.stringValue = String.init(format: "Voltage: %.2f", status.voltage)
            errorsTextField.stringValue =
                String.init(format: "%@: %d", status.isNTBusInUse ? "Bus errors" : "I2C errors", status.errors)
        }
    }

    @IBAction func onClickReset(_ sender: Any) {
        guard let button = sender as? NSButton else {
            return
        }

        button.isEnabled = false
        NotificationCenter.default.post(name: .requestControllerReset, object: nil)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let viewController = segue.destinationController as? AxisDashboardViewController,
           segue.identifier == "embedAxisDashboard" {
            axisDashboardViewControler = viewController
        }
    }
}

extension DashboardViewController: Storm32BGCStatusObserver {
    func storm32BGCController(_ controller: Storm32BGCController, statusUpdated status: Status) {
        if let version = controller.version, let status = controller.status {
            representedObject =  ControllerModel(version: version, status: status)
        }
    }
}
