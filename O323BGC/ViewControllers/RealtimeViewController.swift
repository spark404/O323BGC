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
        graphViewLabel.stringValue = "IMU1 P/R/Y (y = 180°,-180°)"
        graphView.yRangeMax = zoomLevels[currentZoomLevel][0]
        graphView.yRangeMin = zoomLevels[currentZoomLevel][1]

        graphView2Label.stringValue = "AHRS R X/Y/Z (y = 10000/-10000)"
        graphView2.yRangeMax = 10000
        graphView2.yRangeMin = -10000

        graphView3Label.stringValue = "cPID P/R/Y (y = 30°,-30°)"
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
        
        let imu1AnglePitch = data.getFloatValueFor(index: .imu1AnglePitch) / 100.0
        let imu1AngleRoll = data.getFloatValueFor(index: .imu1AngleRoll) / 100.0
        let imu1AngleYaw = data.getFloatValueFor(index: .imu1AngleYaw) / 100.0
        graphView.append(values: [currrentMillis, imu1AnglePitch, imu1AngleRoll, imu1AngleYaw])
        graphView.updateView()

        let imu1AhrsRx = data.getFloatValueFor(index: .imu1AhrsRx)
        let imu1AhrsRy = data.getFloatValueFor(index: .imu1AhrsRy)
        let imu1AhrsRz = data.getFloatValueFor(index: .imu1AhrsRz)
        graphView2.append(values: [currrentMillis, imu1AhrsRx, imu1AhrsRy, imu1AhrsRz])
        graphView2.updateView()

        let cPIDPitchCntrl = data.getFloatValueFor(index: .cPIDPitchCntrl) / 100.0
        let cPIDRollCntrl = data.getFloatValueFor(index: .cPIDRollCntrl) / 100.0
        let cPIDYawCntrl = data.getFloatValueFor(index: .cPIDYawCntrl) / 100.0
        graphView3.append(values: [currrentMillis, cPIDPitchCntrl, cPIDRollCntrl, cPIDYawCntrl])
        graphView3.updateView()
    }
}
