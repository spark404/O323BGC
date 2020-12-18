//
//  ParameterOverviewViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 13/12/2020.
//

import Cocoa

class ParameterOverviewViewController: NSViewController {
    
    @IBOutlet weak var parameterOutlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Do view setup here.
    }
    
    override var representedObject: Any? {
        didSet {
            self.parameterOutlineView.reloadData()
        }
    }
}

extension ParameterOverviewViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if (item != nil) {
            return 0
        } else {
            guard let items = representedObject as? [S32Parameter] else {
                return 0
            }
            return items.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item != nil) {
            return 0
        } else {
            guard let items = representedObject as? [S32Parameter] else {
                return 0
            }
            let sortedItems = items.sorted {
                $0.position < $1.position
            }
            return sortedItems[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
        
}

extension ParameterOverviewViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ParameterNameCell")
        guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else { return nil }

        guard let parameter = item as? S32Parameter else {
            return nil
        }

        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "NameCol") {
            cell.textField?.stringValue = parameter.name
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "ValueCol") {
            cell.textField?.textColor = parameter.defaultValue == parameter.integerValue ? NSColor.secondaryLabelColor : NSColor.labelColor
            cell.textField?.isEditable = false

            if let stringParameter = parameter as? S32StringParameter {
                cell.textField?.stringValue = stringParameter.stringValue
            } else {
                cell.textField?.stringValue = "\(parameter.integerValue)"
            }
        } else {
            cell.textField?.stringValue = "Unknown"
        }
        
        
        return cell
    }
}
