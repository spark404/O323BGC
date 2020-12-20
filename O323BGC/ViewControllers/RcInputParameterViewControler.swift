//
//  RcInputParameterViewControler.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 20/12/2020.
//

import Cocoa

class RcInputParameterViewControler: NSViewController {

    @IBOutlet weak var pitchTrimEditor: NumericParameterEditorView!
    @IBOutlet weak var rollTrimEditor: NumericParameterEditorView!
    @IBOutlet weak var gridView: NSGridView!

    var storm32BGCController: Storm32BGCController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        pitchTrimEditor.delegate = self
        rollTrimEditor.delegate = self
    }

    override func viewDidAppear() {
        // Initialize with parameter values
        guard let parameters = representedObject as? [S32Parameter] else {
            return
        }

        if let paramPitchTrim = parameters.findBy(name: "Rc Dead Band") {
            pitchTrimEditor.parameter = paramPitchTrim as? S32NumericParameter
        }

        if let paramRollTrim = parameters.findBy(name: "Rc Hysteresis") {
            rollTrimEditor.parameter = paramRollTrim as? S32NumericParameter
        }
        
        setParameterForGridElement("Rc Pitch", columnIndex: 0, rowIndex: 0 )
        setParameterForGridElement("Rc Pitch Mode", columnIndex: 0, rowIndex: 1 )
        setParameterForGridElement("Rc Pitch Min", columnIndex: 0, rowIndex: 2 )
        setParameterForGridElement("Rc Pitch Max", columnIndex: 0, rowIndex: 3 )
        setParameterForGridElement("Rc Pitch Trim", columnIndex: 0, rowIndex: 4 )
        setParameterForGridElement("Rc Pitch Speed Limit (0 = off)", columnIndex: 0, rowIndex: 5 )
        setParameterForGridElement("Rc Pitch Accel Limit (0 = off)", columnIndex: 0, rowIndex: 6 )

        setParameterForGridElement("Rc Roll", columnIndex: 1, rowIndex: 0 )
        setParameterForGridElement("Rc Roll Mode", columnIndex: 1, rowIndex: 1 )
        setParameterForGridElement("Rc Roll Min", columnIndex: 1, rowIndex: 2 )
        setParameterForGridElement("Rc Roll Max", columnIndex: 1, rowIndex: 3 )
        setParameterForGridElement("Rc Roll Trim", columnIndex: 1, rowIndex: 4 )
        setParameterForGridElement("Rc Roll Speed Limit (0 = off)", columnIndex: 1, rowIndex: 5 )
        setParameterForGridElement("Rc Roll Accel Limit (0 = off)", columnIndex: 1, rowIndex: 6 )

        setParameterForGridElement("Rc Yaw", columnIndex: 2, rowIndex: 0 )
        setParameterForGridElement("Rc Yaw Mode", columnIndex: 2, rowIndex: 1 )
        setParameterForGridElement("Rc Yaw Min", columnIndex: 2, rowIndex: 2 )
        setParameterForGridElement("Rc Yaw Max", columnIndex: 2, rowIndex: 3 )
        setParameterForGridElement("Rc Yaw Trim", columnIndex: 2, rowIndex: 4 )
        setParameterForGridElement("Rc Yaw Speed Limit (0 = off)", columnIndex: 2, rowIndex: 5 )
        setParameterForGridElement("Rc Yaw Accel Limit (0 = off)", columnIndex: 2, rowIndex: 6 )
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

}

extension RcInputParameterViewControler: NumericParameterEditorViewDelegate {
    func valueDidChange(_ sender: NumericParameterEditorView, new value: Int) {
        guard let changedParameter = sender.parameter else {
            return
        }

        print("Received change for parameter \(changedParameter.name) to \(value)")
        storm32BGCController?.updateParameter(parameter: changedParameter, new: value)
    }
}

extension RcInputParameterViewControler: DropdownParameterEditorViewDelegate {
    func valueDidChange(_ sender: DropdownParameterEditorView, new value: Int) {
        guard let changedParameter = sender.parameter else {
            return
        }

        print("Received change for parameter \(changedParameter.name) to \(value)")
        storm32BGCController?.updateParameter(parameter: changedParameter, new: value)
    }
}
