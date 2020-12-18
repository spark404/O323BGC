//
//  SimplifiedPidViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 16/12/2020.
//

import Cocoa

class SimplifiedPidViewController: NSViewController {
    @IBOutlet weak var controlTitle: NSTextField!
    @IBOutlet weak var dampingSlider: NSSlider!
    @IBOutlet weak var stabilitySlider: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var representedObject: Any? {
        didSet {
            if let pidI = value(forKeyPath: "representedObject.pidI") as? Double,
               let pidD = value(forKeyPath: "representedObject.pidD") as? Double {
                stabilitySlider.doubleValue = pidI / 10 / 2000 * 100
                dampingSlider.doubleValue = pidD / 2000 / 0.8 * 100
            }
        }
    }
    
    @IBAction func onChangeDamping(_ sender: Any) {
        calculateSimplifiedPid()
    }
    
    @IBAction func onChangeStability(_ sender: Any) {
        calculateSimplifiedPid()
    }
    
    private func calculateSimplifiedPid() {
        let kd = dampingSlider.doubleValue * 0.8 / 100.0
        let ki = stabilitySlider.doubleValue * 2000.0 / 100.0
        let kp = sqrt(0.5 * kd * ki)
        
        let pidP = kp * 100
        let pidI = ki * 10
        let pidD = kd * 2000
        
        setValue(pidP, forKeyPath: "representedObject.pidP")
        setValue(pidI, forKeyPath: "representedObject.pidI")
        setValue(pidD, forKeyPath: "representedObject.pidD")

        print("New PID calculated for \(controlTitle.stringValue) : \(pidP),\(pidI),\(pidD)")
    }
}
