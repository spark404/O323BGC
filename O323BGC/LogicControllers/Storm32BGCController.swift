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

    private var connectionObservations = [ObjectIdentifier: ConnectionObservation]()
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
        if devicePath == "simulator" {
            let storm32BGC = Storm32BGCSimulator(fileDescriptor: -1)
            let version = storm32BGC.getVersion()
            print("Connected to board \(version!.name) with version \(version!.version)")

            self.storm32BGC = storm32BGC
            self.internalConnectionState = true
            self.version = version
            self.status = storm32BGC.getStatus()
            self.parameterController = S32ParameterController(storm32BGC: storm32BGC)

            statusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self]_ in
                if let status = self.status {
                    statusUpdated(status: status)
                }
            }

            notifyConnected()
            return true
        }

        print("Connecting to Stomr32BGC device")
        guard let storm32BGC = Storm32BGC(serialDevicePath: devicePath) else {
            return false
        }

        let version = storm32BGC.getVersion()
        if version?.versionNumber != 96 {
            print("No device or no matching version")
            storm32BGC.close()
            return false
        }

        print("Connected to board \(version!.name) with version \(version!.version)")

        self.storm32BGC = storm32BGC
        self.internalConnectionState = true
        self.version = version
        self.status = storm32BGC.getStatus()
        self.parameterController = S32ParameterController(storm32BGC: storm32BGC)

        statusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self]_ in
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
protocol Storm32BGCStatusObserver: class {
    func storm32BGCController(_ controller: Storm32BGCController, statusUpdated status: Status)
}

private extension Storm32BGCController {
    struct Observation {
        weak var observer: Storm32BGCStatusObserver?
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
}

extension Storm32BGCController {
    func addObserver(_ observer: Storm32BGCStatusObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: Storm32BGCStatusObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

// -- Connection observer
protocol Storm32ConnectionObserver: class {
    func storm32BGCControllerConnected(_ controller: Storm32BGCController)
    func storm32BGCControllerDisconnected(_ controller: Storm32BGCController)
}

extension Storm32BGCController {
    func addConnectionObserver(_ observer: Storm32ConnectionObserver) {
        let id = ObjectIdentifier(observer)
        connectionObservations[id] = ConnectionObservation(observer: observer)
    }

    func removeConnectionObserver(_ observer: Storm32ConnectionObserver) {
        let id = ObjectIdentifier(observer)
        connectionObservations.removeValue(forKey: id)
    }
}

private extension Storm32BGCController {
    struct ConnectionObservation {
        weak var observer: Storm32ConnectionObserver?
    }

    func notifyConnected() {
            for (id, observation) in connectionObservations {
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
            for (id, observation) in connectionObservations {
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
