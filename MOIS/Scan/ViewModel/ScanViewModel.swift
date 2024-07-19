import Foundation
import RxSwift
import RxCocoa

class ScanViewModel {
    let deviceScanDataList = BehaviorRelay<[DeviceScanData]>(value: [])
    
    private let bleTimerInterval: TimeInterval
    private var bleTimer: DispatchSourceTimer?
    
    init(bleTimerInterval: TimeInterval = 2.0) {
        self.bleTimerInterval = bleTimerInterval
        startTimer()
    }
    
    private func startTimer() {
        let queueBLE = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".bleTimer")
        self.bleTimer = DispatchSource.makeTimerSource(queue: queueBLE)
        self.bleTimer!.schedule(deadline: .now(), repeating: bleTimerInterval)
        self.bleTimer!.setEventHandler(handler: bleTimerUpdate)
        self.bleTimer!.resume()
    }
    
    private func stopTimer() {
        self.bleTimer?.cancel()
        self.bleTimer = nil
    }
    
    private func bleTimerUpdate() {
        makeDeviceScanDataList()
    }
    
    private func makeDeviceScanDataList() {
        var scanDataList = [DeviceScanData]()
        
        let BLE = BLEManager.shared.getBLE()
        for (key, value) in BLE.Info {
            let rssiValue = mean(of: value.RSSI)
            let category = BLEManager.shared.convertCompanyToCategory(company: value.manufacturer)
            let distance = BLEManager.shared.convertRSSItoDistance(RSSI: rssiValue)
            let scanData = DeviceScanData(state: .STATIC_STATE, category: category, rssi: rssiValue, distance: distance)
            scanDataList.append(scanData)
            print(getLocalTimeString() + " , (BLE Scan) : scanData = \(scanData)")
        }
        print(getLocalTimeString() + " , (BLE Scan) : timer --------------------------------")
        deviceScanDataList.accept(scanDataList)
    }
}
