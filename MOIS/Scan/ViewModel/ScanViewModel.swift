import Foundation
import RxSwift
import RxCocoa

class ScanViewModel {
    let deviceScanDataList = BehaviorRelay<[DeviceScanData]>(value: [])
    let deviceCountDataList = BehaviorRelay<[DeviceCountData]>(value: [])
    private let disposeBag = DisposeBag()
    
    private let bleTimerInterval: TimeInterval
    private var bleTimer: DispatchSourceTimer?
    
    private var filterStateInfo: FilterStateInfo?
    private var filterDeviceInfo: FilterDeviceInfo?
    
    private var filterStateList = [DeviceState]()
    private var filterDeviceList = [String]()
    private var filterDistance: Float = 0
    
    var BLEforState = BLEDevices(Info: [String: BLEInfo]())
    let TRIMMING_TIME_FOR_STATE = 10*1000
    
    init(bleTimerInterval: TimeInterval = 2.0) {
        self.bleTimerInterval = bleTimerInterval
        startTimer()
    }
    
    public func setFilterStateInfo(filterStateInfo: FilterStateInfo) {
        self.filterStateInfo = filterStateInfo
    }
    
    public func setFilterDeviceInfo(filterDeviceInfo: FilterDeviceInfo) {
        self.filterDeviceInfo = filterDeviceInfo
        print(getLocalTimeString() + " , (BLE Scan) ScanViewModel : filterInfo = \(self.filterDeviceInfo)")
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
            print(getLocalTimeString() + " , (BLE Raw) : \(BLE.Info)")
            let UUID = key
            let currentTime = getCurrentTimeInMilliseconds()
            let rssiValue = mean(of: value.RSSI)
            let category = BLEManager.shared.convertCompanyToCategory(company: value.manufacturer)
            let validCategory = convertToValidCategory(category: category)
            var deviceState: DeviceState = .DYNAMIC_STATE
            let distance = BLEManager.shared.convertRSSItoDistance(RSSI: rssiValue)
            
            if let info = BLEforState.Info[UUID] {
                // 기존에 UUID에 매칭된 정보가 있음
                let oldInfoRSSI = info.RSSI
                let oldInfoScannedTime = info.scannedTime
                let newInfo = BLEInfo(pheripherl: value.pheripherl, type: value.type, RSSI: oldInfoRSSI + [rssiValue], scannedTime: oldInfoScannedTime + [currentTime], localName: value.localName, manufacturer: value.manufacturer, operatingSystem: value.operatingSystem, serviceUUID: value.serviceUUID)
                BLEforState.Info.updateValue(newInfo, forKey: UUID)
            } else {
                // UUID에 매칭된 정보가 없음
                let initialInfo = BLEInfo(pheripherl:  value.pheripherl, type:  value.type, RSSI: [rssiValue], scannedTime: [currentTime], localName: value.localName, manufacturer: value.manufacturer, operatingSystem: value.operatingSystem, serviceUUID: value.serviceUUID)
                BLEforState.Info.updateValue(initialInfo, forKey: UUID)
            }
            self.BLEforState = BLEManager.shared.trimBLE(input: BLEforState, scannedTime: currentTime, trimmingTime: TRIMMING_TIME_FOR_STATE)
            
            // Filtering
            if !self.filterStateList.isEmpty {
                if !filterStateList.contains(deviceState) {
                    continue
                }
            }
            
            if !self.filterDeviceList.isEmpty {
                if !filterDeviceList.contains(validCategory) {
                    continue
                }
            }
            
            if self.filterDistance != 0 {
                if Float(distance) > filterDistance {
                    continue
                }
            }
            
            
            let scanData = DeviceScanData(state: deviceState, category: category, rssi: rssiValue, distance: distance)
            scanDataList.append(scanData)
            if rssiValue > -60 {
                print(getLocalTimeString() + " , (BLE Scan) : \(value.pheripherl.identifier.uuidString) , \(value.localName) , \(value.manufacturer) , \(value.serviceUUID) , \(rssiValue)")
            }
//            print(getLocalTimeString() + " , (BLE Scan) : \(value.pheripherl.identifier.uuidString) , \(value.localName) , \(value.manufacturer) , \(value.serviceUUID) , \(rssiValue)")
            
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
            }
        }
        
        for (key, value) in BLEforState.Info {
            let rssiList = value.RSSI
            let rssiVariance = calVariance(buffer: rssiList, bufferMean: mean(of: rssiList))
            let rssiStd = calStd(buffer: rssiList, bufferMean: mean(of: rssiList))
            if (mean(of: rssiList) > -55) {
                print(getLocalTimeString() + " , (BLE State) : id = \(key) // list = \(rssiList) // var = \(rssiVariance) // std = \(rssiStd)")
            }
        }
        print(getLocalTimeString() + " , (BLE State) : timer --------------------------------")
        
        
        print(getLocalTimeString() + " , (BLE Count) : All Count = \(BLE.Info.keys.count)")
        for (category, counts) in categoryCountDict {
            let deviceCountData = DeviceCountData(category: category, fixedCount: counts[0], staticCount: counts[1], dynamicCount: counts[2])
            scanDeviceCountDataList.append(deviceCountData)
        }
        
        scanDataList.sort(by: { $0.rssi > $1.rssi })
        deviceScanDataList.accept(scanDataList)
        
        let predefinedOrder = FILTER_ORDER
        scanDeviceCountDataList.sort { predefinedOrder.firstIndex(of: $0.category)! < predefinedOrder.firstIndex(of: $1.category)! }
        
        for item in scanDeviceCountDataList {
            print(getLocalTimeString() + " , (BLE Count) : category = \(item.category) // d_count = \(item.dynamicCount) // s_count = \(item.staticCount)")
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
    
    func updateStateSwitchValue(state: DeviceState, isOn: Bool) {
        if isOn {
            if !filterStateList.contains(state) {
                filterStateList.append(state)
            }
        } else {
            if let idx = filterStateList.firstIndex(of: state) {
                filterStateList.remove(at: idx)
            }
        }
        print("State: \(state), Switch isOn: \(isOn) , filterStateList = \(filterStateList)")
        makeDeviceScanDataList()
    }
 
    func updateManufacturerSwitchValue(manufacturer: String, isOn: Bool) {
        if isOn {
            if !filterDeviceList.contains(manufacturer) {
                filterDeviceList.append(manufacturer)
            }
        } else {
            if let idx = filterDeviceList.firstIndex(of: manufacturer) {
                filterDeviceList.remove(at: idx)
            }
        }
        print("Manufacturer: \(manufacturer), Switch isOn: \(isOn) , filterDeviceList = \(filterDeviceList)")
        makeDeviceScanDataList()
    }
    
    func updateDistanceSliderValue(value: Float) {
        filterDistance = value
        print("Distance: \(value) m")
    }
}
