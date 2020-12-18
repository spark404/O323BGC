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
    
    var storm32BGCController: Storm32BGCController?
    
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
        graphViewLabel.stringValue = "Pitch / Roll / Yaw (y = 180°,-180°)"
        graphView.yRangeMax = zoomLevels[currentZoomLevel][0]
        graphView.yRangeMin = zoomLevels[currentZoomLevel][1]

        graphView2Label.stringValue = "R x,y,z (y = 10000/-10000)"
        graphView2.yRangeMax = 10000
        graphView2.yRangeMin = -10000

        graphView3Label.stringValue = "Control P/R/Y (y = 30°,-30°)"
        graphView3.yRangeMax = 30
        graphView3.yRangeMin = -30
    }
    
    override func viewDidAppear() {
        _ = storm32BGCController?.realtimeUpdates(timeInterval: 0.1) { [self] in
            doGraphUpdate(data: $0)
        }
    }
    
    override func viewDidDisappear() {
        storm32BGCController?.stopRealtimeUpdates()
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
        graphViewLabel.stringValue = "Pitch / Roll / Yaw (y = \(zoomLevels[currentZoomLevel][0])°,-\(zoomLevels[currentZoomLevel][1])°)"

    }

    func doGraphUpdate(data storm32Data: Storm32Data?) {
        guard let data = storm32Data else {
            return
        }
        
        self.representedObject = data
        cycleTimeValue.intValue = Int32(data.getUInt16ValueFor(index: .cycleTime))
        millisValue.intValue = Int32(data.getUInt16ValueFor(index: .millis))
        
        let currrentMillis = Float(data.getUInt16ValueFor(index: .millis))
        
        let value = data.getFloatValueFor(index: .pitch) / 100.0
        let value2 = data.getFloatValueFor(index: .roll) / 100.0
        let value3 = data.getFloatValueFor(index: .yaw) / 100.0
        graphView.append(values: [currrentMillis, value, value2, value3])
        graphView.updateView()

        let rx = data.getFloatValueFor(index: .rx)
        let ry = data.getFloatValueFor(index: .ry)
        let rz = data.getFloatValueFor(index: .rz)
        graphView2.append(values: [currrentMillis, rx, ry, rz])
        graphView2.updateView()

        let cntrlPitch = data.getFloatValueFor(index: .pitchCntrl) / 100.0
        let cntrlRoll = data.getFloatValueFor(index: .rollCntrl) / 100.0
        let cntrlYaw = data.getFloatValueFor(index: .yawCntrl) / 100.0
        graphView3.append(values: [currrentMillis, cntrlPitch, cntrlRoll, cntrlYaw])
        graphView3.updateView()
    }
}
