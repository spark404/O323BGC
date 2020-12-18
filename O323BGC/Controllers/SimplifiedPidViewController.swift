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
            print("representedObject set on SimplifiedPidViewController")
            if let i = value(forKeyPath: "representedObject.i") as? Double,
               let d = value(forKeyPath: "representedObject.d") as? Double {
                stabilitySlider.doubleValue = i / 10 / 2000 * 100
                stabilitySlider.doubleValue = d / 2000 / 0.8 * 100
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
        
        let p = kp * 100
        let i = ki * 10
        let d = kd * 2000
        
        setValue(p, forKeyPath: "representedObject.p")
        setValue(i, forKeyPath: "representedObject.i")
        setValue(d, forKeyPath: "representedObject.d")
        
        print("New PID calculated for \(controlTitle.stringValue) : \(p),\(i),\(d)")
    }
    
}
