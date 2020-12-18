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
            if let controller = storm32Controller {
                self.splitViewItems.forEach {
                    let viewController = $0.viewController
                    
                    if let menuController = viewController as? MenuViewController {
                        menuController.storm32Controller = controller
                    }
                }
            }
        }
    }
    
    var storm32BGCDataSource: Storm32BGCDataSource? {
        didSet {
            if let dataSource = storm32BGCDataSource {
                self.splitViewItems.forEach {
                    let viewController = $0.viewController
                    
                    if let menuController = viewController as? MenuViewController {
                        menuController.storm32BGCDataSource = dataSource
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

