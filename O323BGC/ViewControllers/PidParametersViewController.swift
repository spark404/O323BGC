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
            guard let parameters = representedObject as? [S32Parameter] else { return }

            if let pitchPidController = self.children[0] as? SimplifiedPidViewController {
                let pidViewModel = PidModel(axis: "Pitch",
                                          pidP: Double(parameters.findBy(name: "Pitch P")!.integerValue),
                                          pidI: Double(parameters.findBy(name: "Pitch I")!.integerValue),
                                          pidD: Double(parameters.findBy(name: "Pitch D")!.integerValue))
                pitchPidController.representedObject = pidViewModel
            }
            if let pitchPidController = self.children[1] as? SimplifiedPidViewController {
                let pidViewModel = PidModel(axis: "Roll",
                                          pidP: Double(parameters.findBy(name: "Roll P")!.integerValue),
                                          pidI: Double(parameters.findBy(name: "Roll I")!.integerValue),
                                          pidD: Double(parameters.findBy(name: "Roll D")!.integerValue))
                pitchPidController.representedObject = pidViewModel
            }
            if let pitchPidController = self.children[2] as? SimplifiedPidViewController {
                let pidViewModel = PidModel(axis: "Yaw",
                                          pidP: Double(parameters.findBy(name: "Yaw P")!.integerValue),
                                          pidI: Double(parameters.findBy(name: "Yaw I")!.integerValue),
                                          pidD: Double(parameters.findBy(name: "Yaw D")!.integerValue))
                pitchPidController.representedObject = pidViewModel
            }
        }
    }
}
