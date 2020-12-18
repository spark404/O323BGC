//
//  Storm32BGCController.swift
//  O323BGC
//
//  Created by Hugo Trippaers on 10/12/2020.
//

import Foundation

class Storm32BGCController: NSObject, Storm32BGCDataSource {
    private var storm32BGC: Storm32BGC?

    private var statusTimer: Timer?

    private var realTimeTimer: Timer?
    private var realTimeRecipient: Storm32BGCRealtimeData?

    private var parameterController: S32ParameterController?

    private var observations = [ObjectIdentifier: Observation]()

    var status: Status?
    var version: Version?

    var data: Storm32Data? {
        storm32BGC?.getData()
    }

    var parameters: [S32Parameter]? {
        parameterController?.retrieveParameters()
    }

    private var internalConnectionState: Bool = false
    var connected: Bool {
        return internalConnectionState
    }

    func connect(devicePath: String) -> Bool {
        let storm32BGC: Storm32BGC
        if devicePath == "simulator" {
            print("Connecting to Stomr32BGC simulator")
            storm32BGC = Storm32BGCSimulator(fileDescriptor: -1)
        } else {
            print("Connecting to Stomr32BGC device")
            if let deviceController = Storm32BGC(serialDevicePath: devicePath) {
                storm32BGC = deviceController
            } else {
                return false
            }
        }

        version = storm32BGC.getVersion()
        if version?.versionNumber != 96 {
            print("No device or no matching version")
            storm32BGC.close()
            return false
        }

        print("Connected to board \(version!.name) with version \(version!.version)")

        self.storm32BGC = storm32BGC
        self.internalConnectionState = true
        self.status = storm32BGC.getStatus()
        self.parameterController = S32ParameterController(storm32BGC: storm32BGC)

        statusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self]_ in
            status = storm32BGC.getStatus()
            if let status = self.status {
                statusUpdated(status: status)
            }
        }

        notifyConnected()
        return true
    }

    func disconnect() {
        self.internalConnectionState = false

        self.realTimeTimer?.invalidate()
        self.realTimeTimer = nil

        self.statusTimer?.invalidate()
        self.statusTimer = nil

        storm32BGC?.close()

        self.parameterController = nil
        self.storm32BGC = nil
        self.version = nil
        self.status = nil

        print("Disconnected from board")
        notifyDisconnected()
    }

    func resetDevice() {
        print("Executing reset on device")
        storm32BGC?.resetBoard()
        print("Done reset on device")
    }

    func stopRealtimeUpdates() {
        print("Stopping realtime updates")
        realTimeTimer?.invalidate()
        realTimeTimer = nil
    }

    func realtimeUpdates(timeInterval: TimeInterval, update: @escaping (_ data: Storm32Data?) -> Void) -> Bool {
        if !internalConnectionState { return false }

        print("Starting realtime updates")
        guard realTimeTimer == nil else {
            print("Realtime timer already exists")
            return false
        }

        realTimeTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            update(self.data)
        }

        return true
    }
}

protocol Storm32BGCRealtimeData {
    func updateData(data: Storm32Data?)
}

protocol Storm32BGCDataSource {
    var status: Status? { get }
    var data: Storm32Data? { get }
    var version: Version? { get }
    var parameters: [S32Parameter]? { get }
}

// -- Status observer
protocol Storm32BGCObserver: class {
    func storm32BGCController(_ controller: Storm32BGCController, statusUpdated status: Status)

    func storm32BGCControllerConnected(_ controller: Storm32BGCController)
    func storm32BGCControllerDisconnected(_ controller: Storm32BGCController)
}

private extension Storm32BGCController {
    struct Observation {
        weak var observer: Storm32BGCObserver?
    }

    func statusUpdated(status: Status) {
        for (id, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }

            observer.storm32BGCController(self, statusUpdated: status)
        }
    }

    func notifyConnected() {
        for (id, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }

            observer.storm32BGCControllerConnected(self)
        }
    }

    func notifyDisconnected() {
        for (id, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }

            observer.storm32BGCControllerDisconnected(self)
        }
    }
}

extension Storm32BGCController {
    func addObserver(_ observer: Storm32BGCObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: Storm32BGCObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

extension Storm32BGCObserver {
    func storm32BGCController(_ controller: Storm32BGCController, statusUpdated status: Status) {}

    func storm32BGCControllerConnected(_ controller: Storm32BGCController) {}
    func storm32BGCControllerDisconnected(_ controller: Storm32BGCController) {}
}
