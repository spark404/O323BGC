//
//  MenuViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 07/12/2020.
//

import Foundation
import Cocoa

class MenuViewController: NSViewController {
    var storm32BGCDataSource: Storm32BGCDataSource?
    var storm32Controller: Storm32BGCController? {
        didSet {
            if let controller = storm32Controller {
                controller.addConnectionObserver(self)
            }
        }
    }
    
    @IBOutlet var treeController: NSTreeController!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @objc dynamic var menuStructure = [MenuItem]()
    
    private enum DetailTabs: Int {
        case Dashboard
        case Datadisplay
        case Parameters
        case PidParameters
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuStructure.append(contentsOf: MenuItemFactory().items())
        outlineView.expandItem(nil, expandChildren: true)
    }
        
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func selectViewForMenuItem(menuItem: MenuItem) {
        switch (menuItem.name) {
        case "Dashboard":
            if let datasource = storm32BGCDataSource {
                if let v = datasource.version, let s = datasource.status {
                    setRepresentedObjectForDetailTab(tab: .Dashboard, object: ControllerModel(version: v, status: s))
                }
            }
            if let dashboard = getDetailTab(index: DetailTabs.Dashboard.rawValue) as? DashboardViewController {
                storm32Controller?.addObserver(dashboard)
            }
            selectDetailTab(tab: .Dashboard)
        case "Dataview":
            selectDetailTab(tab: .Datadisplay)
        case "All Parameters":
            setRepresentedObjectForDetailTab(tab: .Parameters, object: storm32BGCDataSource?.parameters)
            selectDetailTab(tab: .Parameters)
        default:
            setRepresentedObjectForDetailTab(tab: .Parameters, object: storm32BGCDataSource?.parameters)
            selectDetailTab(tab: .PidParameters)
        }
    }
    
    private func setRepresentedObjectForDetailTab(tab: DetailTabs, object: Any?) {
        let tab = getDetailTab(index: tab.rawValue)
        tab?.setValue(object, forKey: "representedObject")
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
        guard let treeNode = item as? NSTreeNode else {
            return false
        }
        
        if let menuItem = treeNode.representedObject as? MenuItem {
            return !menuItem.selectable
        }
        return false
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let menuItem = treeController.selectedNodes[0].representedObject as? MenuItem {
            selectViewForMenuItem(menuItem: menuItem)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        guard let treeNode = item as? NSTreeNode else {
            return true
        }
        
        if let menuItem = treeNode.representedObject as? MenuItem {
            return menuItem.selectable
        }
        
        return true
    }
}
extension MenuViewController: Storm32ConnectionObserver {
    func storm32BGCControllerDisconnected(_ controller: Storm32BGCController) {
        print ("Received disconnected notification")
        treeController.setSelectionIndexPath(IndexPath(index: 0))
        
        guard let splitViewController = parent as? MainSplitViewController else {
            return
        }
        
        guard let tabController = splitViewController.splitViewItems[1].viewController as? NSTabViewController else {
            return
        }

        tabController.tabViewItems.forEach {
            $0.viewController?.setValue(nil, forKey: "representedObject")
        }
        
        setRepresentedObjectForDetailTab(tab: .Dashboard, object: nil)
        if let dashboard = getDetailTab(index: DetailTabs.Dashboard.rawValue) as? DashboardViewController {
            storm32Controller?.removeObserver(dashboard)
        }
        //selectDetailTab(tab: .Dashboard)
    }
    
    func storm32BGCControllerConnected(_ controller: Storm32BGCController) {
        print ("Received connected notification")
        treeController.setSelectionIndexPath(IndexPath(index: 0))

        if let datasource = storm32BGCDataSource {
            if let v = datasource.version, let s = datasource.status {
                setRepresentedObjectForDetailTab(tab: .Dashboard, object: ControllerModel(version: v, status: s))
            }
        }
        if let dashboard = getDetailTab(index: DetailTabs.Dashboard.rawValue) as? DashboardViewController {
            storm32Controller?.addObserver(dashboard)
        }

    }
}

