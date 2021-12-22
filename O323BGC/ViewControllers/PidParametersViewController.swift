//
//  PidParametersViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 16/12/2020.
//

import Cocoa

class PidParametersViewController: NSViewController {

    @IBOutlet weak var pitchPidContainer: NSView!
    @IBOutlet weak var rollPidContainer: NSView!
    @IBOutlet weak var yawPidContainer: NSView!
    @IBOutlet weak var pidOverviewGrid: NSGridView!
    @IBOutlet weak var pidCalculatedGrid: NSGridView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

    }
    
    override var representedObject: Any? {
        didSet {
            if let pitchPidController = self.children[0] as? SimplifiedPidViewController,
               let pidViewModel = getViewModelForAxis(axis: "Pitch") {
                pitchPidController.representedObject = pidViewModel
                pitchPidController.delegate = self
                updateGridColumn(grid: pidOverviewGrid, column: 1, model: pidViewModel)
                updateGridColumn(grid: pidCalculatedGrid, column: 1, model: pidViewModel)
            }
            if let pitchPidController = self.children[1] as? SimplifiedPidViewController,
               let pidViewModel = getViewModelForAxis(axis: "Roll") {
                pitchPidController.representedObject = pidViewModel
                pitchPidController.delegate = self
                updateGridColumn(grid: pidOverviewGrid, column: 2, model: pidViewModel)
                updateGridColumn(grid: pidCalculatedGrid, column: 2, model: pidViewModel)
            }
            if let pitchPidController = self.children[2] as? SimplifiedPidViewController,
               let pidViewModel = getViewModelForAxis(axis: "Yaw") {
                pitchPidController.representedObject = pidViewModel
                pitchPidController.delegate = self
                updateGridColumn(grid: pidOverviewGrid, column: 3, model: pidViewModel)
                updateGridColumn(grid: pidCalculatedGrid, column: 3, model: pidViewModel)
            }
        }
    }

    func getViewModelForAxis(axis: String) -> PidModel? {
        guard let parameters = representedObject as? [S32Parameter] else { return nil }

        guard let pidPParam = parameters.findBy(name: "\(axis) P"),
              let pidIParam = parameters.findBy(name: "\(axis) I"),
              let pidDParam = parameters.findBy(name: "\(axis) D"),
              let axisVmaxParam = parameters.findBy(name: "\(axis) Motor Vmax") else {
            return nil
        }

        return PidModel(axis: axis,
                        pidP: Double(pidPParam.integerValue),
                        pidI: Double(pidIParam.integerValue),
                        pidD: Double(pidDParam.integerValue),
                        vMax: axisVmaxParam.integerValue)

    }

    func updateGridColumn(grid: NSGridView, column index: Int, model: PidModel) {
        grid.cell(atColumnIndex: index, rowIndex: 1)
            .contentView?.setValue(model.pidP, forKey: "integerValue")
        grid.cell(atColumnIndex: index, rowIndex: 2)
            .contentView?.setValue(model.pidI, forKey: "integerValue")
        grid.cell(atColumnIndex: index, rowIndex: 3)
            .contentView?.setValue(model.pidD, forKey: "integerValue")
        grid.cell(atColumnIndex: index, rowIndex: 4)
            .contentView?.setValue(model.vMax, forKey: "integerValue")

    }
}

extension PidParametersViewController: SimplifiedPidViewControllerDelegate {
    func simplifiedPidView(_ sender: SimplifiedPidViewController, model update: PidModel) {
        print("Processing update for \(update.axis)")
        switch update.axis {
        case "Pitch":
            updateGridColumn(grid: pidCalculatedGrid, column: 1, model: update)
        case "Roll":
            updateGridColumn(grid: pidCalculatedGrid, column: 2, model: update)
        case "Yaw":
            updateGridColumn(grid: pidCalculatedGrid, column: 3, model: update)
        default:
            print("Unable to determine axis")
        }

    }


}
