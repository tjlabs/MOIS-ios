import Foundation
import RxSwift
import RxCocoa

class ScanViewModel {
    let deviceScanDataList = BehaviorRelay<[DeviceScanData]>(value: [])
    let deviceCountDataList = BehaviorRelay<[DeviceCountData]>(value: [])
    
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
        var categoryCountDict = [String: [Int]]()
        var scanDeviceCountDataList = [DeviceCountData]()
        
        let BLE = BLEManager.shared.getBLE()
        for (key, value) in BLE.Info {
            let rssiValue = mean(of: value.RSSI)
            let category = BLEManager.shared.convertCompanyToCategory(company: value.manufacturer)
            let distance = BLEManager.shared.convertRSSItoDistance(RSSI: rssiValue)
            let scanData = DeviceScanData(state: .STATIC_STATE, category: category, rssi: rssiValue, distance: distance)
            scanDataList.append(scanData)
            print(getLocalTimeString() + " , (BLE Scan) : scanData = \(scanData)")
            
            let categoryKey = category
            if var counts = categoryCountDict[categoryKey] {
                if scanData.state == .STATIC_STATE {
                    counts[0] += 1
                } else {
                    counts[1] += 1
                }
                categoryCountDict[categoryKey] = counts
            } else {
                categoryCountDict[categoryKey] = scanData.state == .STATIC_STATE ? [1, 0] : [0, 1]
            }
        }
        
        for (category, counts) in categoryCountDict {
            let deviceCountData = DeviceCountData(category: category, staticCount: counts[0], dynamicCount: counts[1])
            scanDeviceCountDataList.append(deviceCountData)
        }
        
        print(getLocalTimeString() + " , (BLE Scan) : timer --------------------------------")
        scanDataList.sort(by: { $0.rssi > $1.rssi })
        deviceScanDataList.accept(scanDataList)
        
        let predefinedOrder = ["Apple", "Google", "Samsung", "TJLABS", "Etc"]
        scanDeviceCountDataList.sort { predefinedOrder.firstIndex(of: $0.category)! < predefinedOrder.firstIndex(of: $1.category)! }
        
        deviceCountDataList.accept(scanDeviceCountDataList)
    }
}
