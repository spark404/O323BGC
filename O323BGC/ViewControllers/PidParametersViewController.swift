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
            guard (representedObject as? [[String:Any]]) != nil else {
                return
            }
            
            if let pitchPidController = self.children[0] as? SimplifiedPidViewController {
                let testObject = PidModel(axis: "Pitch", pidP: 400, pidI: 1000, pidD: 500)
                pitchPidController.representedObject = testObject
            }
            if let pitchPidController = self.children[1] as? SimplifiedPidViewController {
                let testObject = PidModel(axis: "Roll", pidP: 400, pidI: 1000, pidD: 500)
                pitchPidController.representedObject = testObject
            }
            if let pitchPidController = self.children[2] as? SimplifiedPidViewController {
                let testObject = PidModel(axis: "Yaw", pidP: 400, pidI: 1000, pidD: 500)
                pitchPidController.representedObject = testObject
            }
        }
    }
}
