//
//  RealtimeViewController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 12/12/2020.
//

import Foundation
import Cocoa

class RealtimeViewController: NSViewController {

    @IBOutlet weak var cycleTimeValue: NSTextField!
    @IBOutlet weak var millisValue: NSTextField!
    @IBOutlet weak var graphViewLabel: NSTextField!
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var graphView2Label: NSTextField!
    @IBOutlet weak var graphView2: GraphView!
    @IBOutlet weak var graphView3Label: NSTextFieldCell!
    @IBOutlet weak var graphView3: GraphView!
    
    let zoomLevels = [
        [ 180.0, -180.0],
        [ 90.0, -90.0],
        [ 30.0, -30.0],
        [ 15.0, -15.0],
        [ 5.0, -5.0],
        [ 1.5, -1.5]
    ]
    var currentZoomLevel = 0
    
    override func viewDidLoad() {
        graphViewLabel.stringValue = "Pitch / Roll / Yaw"
        graphView.yRangeMax = zoomLevels[currentZoomLevel][0]
        graphView.yRangeMin = zoomLevels[currentZoomLevel][1]

        graphView2Label.stringValue = "R x,y,z"
        graphView2.yRangeMax = 10000
        graphView2.yRangeMin = -10000

        graphView3Label.stringValue = "Control P/R/Y"
        graphView3.yRangeMax = 30
        graphView3.yRangeMin = -30
    }
    
    override func viewDidAppear() {
        NotificationCenter.default.post(name: .startRealtimeData, object: self)
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.post(name: .stopRealtimeData, object: self)
    }
    
    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func onZoomClick(_ sender: Any) {
        currentZoomLevel += 1
        if currentZoomLevel >= zoomLevels.count {
            currentZoomLevel = 0
        }
        graphView.yRangeMax = zoomLevels[currentZoomLevel][0]
        graphView.yRangeMin = zoomLevels[currentZoomLevel][1]

    }
}

extension RealtimeViewController: Storm32BGCRealtimeData {
    func updateData(data: Storm32Data) {
        self.representedObject = data
        cycleTimeValue.intValue = Int32(data.getUInt16ValueFor(index: .CycleTime))
        millisValue.intValue = Int32(data.getUInt16ValueFor(index: .Millis))
        
        let currrentMillis = Float(data.getUInt16ValueFor(index: .Millis))
        
        let value = Float(data.getInt16ValueFor(index: .Pitch)) / 100.0
        let value2 = Float(data.getInt16ValueFor(index: .Roll)) / 100.0
        let value3 = Float(data.getInt16ValueFor(index: .Yaw)) / 100.0
        graphView.append(values: [currrentMillis, value, value2, value3])
        graphView.updateView()

        let rx = Float(data.getInt16ValueFor(index: .Rx))
        let ry = Float(data.getInt16ValueFor(index: .Ry))
        let rz = Float(data.getInt16ValueFor(index: .Rz))
        graphView2.append(values: [currrentMillis, rx, ry, rz])
        // print("Appending R \(rx),\(ry),\(rz)")
        graphView2.updateView()

        let cntrlPitch = Float(data.getInt16ValueFor(index: .PitchCntrl)) / 100.0
        let cntrlRoll = Float(data.getInt16ValueFor(index: .RollCntrl)) / 100.0
        let cntrlYaw = Float(data.getInt16ValueFor(index: .YawCntrl)) / 100.0
        graphView3.append(values: [currrentMillis, cntrlPitch, cntrlRoll, cntrlYaw])
        graphView3.updateView()
    }
}
