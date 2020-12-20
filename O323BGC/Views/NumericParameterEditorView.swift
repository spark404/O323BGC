//
//  NumericParameterEditorView.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 20/12/2020.
//

import Cocoa

@IBDesignable
class NumericParameterEditorView: NSView {

    @IBOutlet var contentView: NSView!
    @IBOutlet weak var parameterName: NSTextField!
    @IBOutlet weak var parameterValueSlider: NSSlider!
    @IBOutlet weak var parameterValueField: NSTextField!

    weak var delegate: NumericParameterEditorViewDelegate?

    var parameter: S32NumericParameter? {
        didSet {
            updateState()
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    private func setup() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        nib.instantiate(withOwner: self, topLevelObjects: nil)

        addSubview(contentView)

        updateState()
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    private func updateState() {
        guard let current = self.parameter else {
            return
        }

        parameterName.stringValue = current.name
        parameterValueField.stringValue = "\(current.integerValue)"
        parameterValueField.textColor = current.integerValue != current.defaultValue ? NSColor.labelColor : NSColor.secondaryLabelColor

        parameterValueSlider.integerValue = current.integerValue
        parameterValueSlider.minValue = Double(current.minValue)
        parameterValueSlider.maxValue = Double(current.maxValue)
        parameterValueSlider.altIncrementValue = Double(current.steps)
    }

    @IBAction func onChangeParameterValueSlider(_ sender: NSSlider) {
        let newValue = roundToStep(sender.integerValue)
        parameterValueSlider.integerValue = newValue
        parameterValueField.stringValue = "\(sender.integerValue)"
        
        if NSApplication.shared.currentEvent?.type == .leftMouseUp {
            valueUpdated()
        }
    }

    @IBAction func onChangeParameterValueField(_ sender: NSTextField) {
        let newValue = roundToStep(Int(sender.stringValue) ?? 0)
        parameterValueSlider.integerValue = newValue
        sender.stringValue = "\(parameterValueSlider.integerValue)"
        valueUpdated()
    }

    private func valueUpdated() {
        guard let current = self.parameter else {
            return
        }

        parameterValueField.textColor = parameterValueSlider.integerValue != current.defaultValue ? NSColor.labelColor : NSColor.secondaryLabelColor

        delegate?.valueDidChange(self, new: parameterValueSlider.integerValue)
    }

    private func roundToStep(_ value: Int) -> Int {
        guard let step = parameter?.steps else {
            return value
        }
        return  step != 1 ? (value / step) * step : value
    }
}

protocol NumericParameterEditorViewDelegate: class {
    func valueDidChange(_ sender: NumericParameterEditorView, new value: Int)
}
