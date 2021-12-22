//
//  MotorParameterViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 25/01/2021.
//

import Cocoa

class MotorParameterViewController: NSViewController {
    var storm32BGCController: Storm32BGCController?

    @IBOutlet weak var gridView: NSGridView!
    @IBOutlet weak var motorMapping: DropdownParameterEditorView!

    override func viewDidAppear() {
        // Initialize with parameter values
        guard let parameters = representedObject as? [S32Parameter] else {
            return
        }


        if let param = parameters.findBy(name: "Motor Mapping") as? S32StringParameter {
            motorMapping.delegate = self
            motorMapping.parameter = param
        }

        for (index, element) in ["Pitch", "Roll", "Yaw"].enumerated() {
            setParameterForGridElement("\(element) Motor Usage", columnIndex: index, rowIndex: 1 )
            setParameterForGridElement("\(element) Motor Poles", columnIndex: index, rowIndex: 2 )
            setParameterForGridElement("\(element) Motor Direction", columnIndex: index, rowIndex: 3 )
            setParameterForGridElement("\(element) Offset", columnIndex: index, rowIndex: 4 )
            setParameterForGridElement("\(element) Startup Motor Pos", columnIndex: index, rowIndex: 5 )
        }
    }

    func setParameterForGridElement(_ name: String, columnIndex: Int, rowIndex: Int) {
        guard let parameters = representedObject as? [S32Parameter] else {
            return
        }

        if let param = parameters.findBy(name: name) as? S32NumericParameter,
           let paramView = gridView
            .cell(atColumnIndex: columnIndex, rowIndex: rowIndex)
            .contentView as? NumericParameterEditorView {
            paramView.delegate = self
            paramView.parameter = param
        } else if let param = parameters.findBy(name: name) as? S32StringParameter,
                  let paramView = gridView
                    .cell(atColumnIndex: columnIndex, rowIndex: rowIndex)
                    .contentView as? DropdownParameterEditorView {
            paramView.delegate = self
            paramView.parameter = param
        }
    }

    func showUpdateFailedAlert() {
        let alert = NSAlert()
        alert.messageText = "Update failed"
        alert.informativeText = "The controller reported an error while processing the updated values"
        alert.beginSheetModal(for: self.view.window!) { (response) in

                }
    }

}

extension MotorParameterViewController: NumericParameterEditorViewDelegate {
    func valueDidChange(_ sender: NumericParameterEditorView, new value: Int) {
        guard let changedParameter = sender.parameter else {
            return
        }

        print("Received change for parameter \(changedParameter.name) to \(value)")
        if !(storm32BGCController?.updateParameter(parameter: changedParameter, new: value) ?? false) {
            showUpdateFailedAlert()
        }
    }
}

extension MotorParameterViewController: DropdownParameterEditorViewDelegate {
    func valueDidChange(_ sender: DropdownParameterEditorView, new value: Int) {
        guard let changedParameter = sender.parameter else {
            return
        }

        print("Received change for parameter \(changedParameter.name) to \(value)")
        if !(storm32BGCController?.updateParameter(parameter: changedParameter, new: value) ?? false) {
            showUpdateFailedAlert()
        }
    }
}
