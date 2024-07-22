import Foundation
import RxSwift
import RxCocoa

class ScanViewModel {
    let deviceScanDataList = BehaviorRelay<[DeviceScanData]>(value: [])
    let deviceCountDataList = BehaviorRelay<[DeviceCountData]>(value: [])
    private let disposeBag = DisposeBag()
    
    private let bleTimerInterval: TimeInterval
    private var bleTimer: DispatchSourceTimer?
    
    private var filterInfo: FilterInfo?
    
    init(bleTimerInterval: TimeInterval = 2.0) {
        self.bleTimerInterval = bleTimerInterval
        startTimer()
    }
    
    public func setFilterModel(filterInfo: FilterInfo) {
        self.filterInfo = filterInfo
        print(getLocalTimeString() + " , (BLE Scan) ScanViewModel : filterInfo = \(self.filterInfo)")
    }
    
    private func makeFilter() {
        if let filterInfo = self.filterInfo {
            filterInfo.manufacuterers
            filterInfo.distance
        }
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
        for (_, value) in BLE.Info {
            let rssiValue = mean(of: value.RSSI)
            let category = BLEManager.shared.convertCompanyToCategory(company: value.manufacturer)
            let validCategory = convertToValidCategory(category: category)
            let distance = BLEManager.shared.convertRSSItoDistance(RSSI: rssiValue)
            let scanData = DeviceScanData(state: .STATIC_STATE, category: category, rssi: rssiValue, distance: distance)
            scanDataList.append(scanData)
            print(getLocalTimeString() + " , (BLE Scan) : \(value.pheripherl.identifier.uuidString) , \(value.localName) , \(value.manufacturer) , \(value.serviceUUID) , \(rssiValue)")
//            print(getLocalTimeString() + " , (BLE Scan) : scanData = \(scanData)")
            
            let categoryKey = validCategory
            if var counts = categoryCountDict[categoryKey] {
                if scanData.state == .FIXED_STATE {
                    counts[0] += 1
                } else if scanData.state == .STATIC_STATE {
                    counts[1] += 1
                } else {
                    counts[2] += 1
                }
                categoryCountDict[categoryKey] = counts
            } else {
                if scanData.state == .FIXED_STATE {
                    categoryCountDict[categoryKey] = [1, 0, 0]
                } else if scanData.state == .STATIC_STATE {
                    categoryCountDict[categoryKey] = [0, 1, 0]
                } else {
                    categoryCountDict[categoryKey] = [0, 0, 1]
                }
//                categoryCountDict[categoryKey] = scanData.state == .STATIC_STATE ? [1, 0] : [0, 1]
            }
        }
        print(getLocalTimeString() + " , (BLE Scan) : All Count = \(BLE.Info.keys.count)")
        
        for (category, counts) in categoryCountDict {
            let deviceCountData = DeviceCountData(category: category, fixedCount: counts[0], staticCount: counts[1], dynamicCount: counts[2])
            scanDeviceCountDataList.append(deviceCountData)
        }
        
        scanDataList.sort(by: { $0.rssi > $1.rssi })
        deviceScanDataList.accept(scanDataList)
        
        let predefinedOrder = FILTER_ORDER
        scanDeviceCountDataList.sort { predefinedOrder.firstIndex(of: $0.category)! < predefinedOrder.firstIndex(of: $1.category)! }
        
        for item in scanDeviceCountDataList {
            print(getLocalTimeString() + " , (BLE Scan) : category = \(item.category) // d_count = \(item.dynamicCount) // s_count = \(item.staticCount)")
        }
        
        print(getLocalTimeString() + " , (BLE Scan) : timer --------------------------------")
        deviceCountDataList.accept(scanDeviceCountDataList)
    }
    
    private func convertToValidCategory(category: String) -> String {
        var validCategoryName: String = category
        
        if !FILTER_ORDER.contains(validCategoryName) {
            validCategoryName = FILTER_ORDER[FILTER_ORDER.count-1]
        }
        
        return validCategoryName
    }
    
    func updateManufacturerSwitchValue(manufacturer: String, isOn: Bool) {
        print("Manufacturer: \(manufacturer), Switch isOn: \(isOn)")
    }
    
    func updateDistanceSliderValue(value: Float) {
        print("Distance: \(value) m")
    }
}
