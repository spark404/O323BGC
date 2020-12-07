//
//  ViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 06/12/2020.
//

import Foundation
import Cocoa
import IOKit.serial

class MainSplitViewController: NSSplitViewController {
    var serial: Serial = Serial()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

