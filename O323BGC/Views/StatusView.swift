//
//  StatusView.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 09/12/2020.
//

import Foundation
import Cocoa

@IBDesignable
class StatusView: NSView {
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var statusImageView: NSImageView!
    @IBOutlet weak var statusLabelView: NSTextField!
    @IBOutlet weak var statusItemField: NSTextField!
    
    @IBInspectable var present: Bool = false {
        didSet {
            updateTristateLed()
        }
    }
    
    @IBInspectable var status: Bool = false {
        didSet {
            updateTristateLed()
        }
    }
    
    @IBInspectable var statusText: String {
        set {
            statusLabelView.stringValue = newValue
        }
        get {
            return statusLabelView.stringValue
        }
    }
    
    @IBInspectable var statusItem: String {
        set {
            statusItemField.stringValue = newValue
        }
        get {
            return statusItemField.stringValue
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
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func updateTristateLed() {
        if (present) {
            statusImageView.image = status ? NSImage(named: "StatusGreen") : NSImage(named: "StatusRed")
        } else {
            statusImageView.image = NSImage(named: "StatusGrey")
        }
    }
    
    
}
