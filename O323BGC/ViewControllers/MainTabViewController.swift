//
//  MainTabViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 17/12/2020.
//

import Cocoa

class MainTabViewController: NSTabViewController {
    var storm32BGCController: Storm32BGCController? {
        didSet {
            print("MainTabViewController storm32Controller.didSet")
            tabViewItems.forEach {
                print("Attempting to inject Storm32BGCController")
                if var controller = $0.viewController as? Storm32ControllerProtocol {
                    controller.storm32BGCController = storm32BGCController
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
