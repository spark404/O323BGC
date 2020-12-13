//
//  MenuViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation
import Cocoa

class MenuViewController: NSViewController {
    
    @IBOutlet var treeController: NSTreeController!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @objc dynamic var menuStructure = [MenuItem]()
    
    var storm32BGCController: Storm32BGCController?
    
    private enum DetailTabs: Int {
        case Dashboard
        case Datadisplay
        case Parameters
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuStructure.append(contentsOf: MenuItemFactory().items())
    
        NotificationCenter.default.addObserver(self, selector: #selector(connectSerial), name: .connectSerial, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectSerial), name: .disconnectSerial, object: nil)
    }
    
    override func viewDidDisappear() {
        storm32BGCController?.disconnect()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func connectSerial(message: NSNotification) {
        guard let path = message.object as? String else {
            print ("Received connect notification without path")
            NotificationCenter.default.post(name: .serialDisconnected, object: nil)
            return
        }
        
        storm32BGCController = Storm32BGCController(devicePath: path)
        if (storm32BGCController == nil) {
            NotificationCenter.default.post(name: .serialDisconnected, object: nil)
            return
        }
        storm32BGCController?.delegate = self
        
        treeController.setSelectionIndexPath(IndexPath(index: 0))
        NotificationCenter.default.post(name: .serialConnected, object: nil)
    }
    
    @objc func disconnectSerial(message: NSNotification) {
        if let dashboard = getDetailTab(index: 0) as? DashboardViewController {
            dashboard.representedObject = nil
        }
        
        if let controller = storm32BGCController {
            controller.disconnect()
        }
        
        treeController.setSelectionIndexPath(IndexPath(index: 0))
        NotificationCenter.default.post(name: .serialDisconnected, object: nil)
    }
    
    func selectViewForMenuItem(menuItem: MenuItem) {
        switch (menuItem.name) {
        case "Dashboard":
            selectDetailTab(tab: .Dashboard)
        case "Dataview":
            selectDetailTab(tab: .Datadisplay)
        default:
            selectDetailTab(tab: .Parameters)
        }
    }
    
    private func selectDetailTab(tab: DetailTabs) {
        guard let splitViewController = parent as? MainSplitViewController else {
            return
        }
        
        guard let tabController = splitViewController.splitViewItems[1].viewController as? NSTabViewController else {
            return
        }
        
        tabController.selectedTabViewItemIndex = tab.rawValue
    }
    
    func getDetailTab(index: Int) -> NSViewController? {
        guard let splitViewController = parent as? MainSplitViewController else {
            return nil
        }
        
        guard let tabController = splitViewController.splitViewItems[1].viewController as? NSTabViewController else {
            return nil
        }

        return tabController.tabViewItems[index].viewController
    }
    
}

extension MenuViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        return outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("HeaderCell"), owner: self)
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return false
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let menuItem = treeController.selectedNodes[0].representedObject as? MenuItem {
            selectViewForMenuItem(menuItem: menuItem)
        }
    }
}

extension MenuViewController: Storm32BGCStatusDelegate {
    func didUpdateStatus(_ sender: Storm32BGCController) {
        let c = ControllerModel(version: sender.version!, status: sender.status!)
        getDetailTab(index: 0)?.representedObject = c
    }
}
