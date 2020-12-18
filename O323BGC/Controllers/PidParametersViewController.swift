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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var representedObject: Any? {
        didSet {
            print("representedObject set on PidParametersViewController")
            guard let parameters = representedObject as? [[String:Any]] else {
                return
            }
            
            if let pitchPidController = self.children[0] as? SimplifiedPidViewController {
                let testObject = PidModel(axis: "Pitch", p: 400, i: 1000, d: 500)
                pitchPidController.representedObject = testObject
            }
            if let pitchPidController = self.children[1] as? SimplifiedPidViewController {
                let testObject = PidModel(axis: "Roll", p: 400, i: 1000, d: 500)
                pitchPidController.representedObject = testObject
            }
            if let pitchPidController = self.children[2] as? SimplifiedPidViewController {
                let testObject = PidModel(axis: "Yaw", p: 400, i: 1000, d: 500)
                pitchPidController.representedObject = testObject
            }
        }
    }
}
