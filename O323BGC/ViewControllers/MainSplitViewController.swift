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
    var storm32Controller: Storm32BGCController? {
        didSet {
            print("MainSplitViewController storm32Controller.didSet")
            if let controller = storm32Controller {
                self.splitViewItems.forEach {
                    if var viewController = $0.viewController as? Storm32ControllerProtocol {
                        viewController.storm32BGCController = controller
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainSplitViewController viewDidLoad")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
