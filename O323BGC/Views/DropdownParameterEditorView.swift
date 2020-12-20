//
//  DropdownParameterEditor.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 20/12/2020.
//

import Cocoa

@IBDesignable
class DropdownParameterEditorView: NSView {

    @IBOutlet var contentView: NSView!
    @IBOutlet weak var parameterName: NSTextField!
    @IBOutlet weak var parameterOptionList: NSPopUpButton!

    weak var delegate: DropdownParameterEditorViewDelegate?

    var parameter: S32StringParameter? {
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
            self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    @IBAction func onChangeDropdown(_ sender: NSPopUpButton) {
        delegate?.valueDidChange(self, new: sender.indexOfSelectedItem)
    }

    private func updateState() {
        guard let current = self.parameter else {
            return
        }

        parameterName.stringValue = current.name
        parameterOptionList.removeAllItems()
        current.optionList.forEach {
            parameterOptionList.addItem(withTitle: $0)
        }
        parameterOptionList.selectItem(at: current.integerValue)
        
    }

}

protocol DropdownParameterEditorViewDelegate: class {
    func valueDidChange(_ sender: DropdownParameterEditorView, new value: Int)
}
