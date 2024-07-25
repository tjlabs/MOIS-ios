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
    private var filterDistance: Float = 30
    
    var BLEforState = BLEDevices(Info: [String: BLEInfo]())
    var DeviceCountInfo = DeviceCountBuffer(Info: [String: CountInfo]())
    let TRIMMING_TIME_FOR_STATE = 10*1000
    let STATIC_THRESHOLD: Double = 8
    
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
        let currentTime = getCurrentTimeInMilliseconds()
        var scanDataList = [DeviceScanData]()
        var categoryCountDict = [String: [Int]]()
        var scanDeviceCountDataList = [DeviceCountData]()

        let BLE = BLEManager.shared.getBLE()
        for (key, value) in BLE.Info {
//            print(getLocalTimeString() + " , (BLE Raw) : \(BLE.Info)")
            let UUID = key
            let rssiValue = mean(of: value.RSSI)
//            let category = BLEManager.shared.convertCompanyToCategory(company: value.manufacturer)
            let category = value.category
            let validCategory = convertToValidCategory(category: category)
            var deviceState: DeviceState = .DYNAMIC_STATE
            let distance = BLEManager.shared.convertRSSItoDistance(RSSI: rssiValue)
            
            if let info = BLEforState.Info[UUID] {
                // 기존에 UUID에 매칭된 정보가 있음
                let oldInfoRSSI = info.RSSI
                let oldInfoScannedTime = info.scannedTime
                let newInfo = BLEInfo(pheripherl: value.pheripherl, category: value.category, type: value.type, RSSI: oldInfoRSSI + [rssiValue], scannedTime: oldInfoScannedTime + [currentTime], localName: value.localName, manufacturer: value.manufacturer, serviceUUID: value.serviceUUID)
                deviceState = decideDeviceState(deviceType: value.type, rssiList: newInfo.RSSI)
                BLEforState.Info.updateValue(newInfo, forKey: UUID)
            } else {
                // UUID에 매칭된 정보가 없음
                let initialInfo = BLEInfo(pheripherl:  value.pheripherl, category: value.category, type:  value.type, RSSI: [rssiValue], scannedTime: [currentTime], localName: value.localName, manufacturer: value.manufacturer, serviceUUID: value.serviceUUID)
                deviceState = decideDeviceState(deviceType: value.type, rssiList: initialInfo.RSSI)
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
            print(getLocalTimeString() + " , (BLE Scan) : \(value.pheripherl.identifier.uuidString) , \(value.localName) , \(value.category) , \(value.manufacturer), \(deviceState) , \(value.serviceUUID) , \(rssiValue)")
            
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
        
        scanDataList.sort(by: { $0.rssi > $1.rssi })
        deviceScanDataList.accept(scanDataList)
        
//        for (key, value) in BLEforState.Info {
//            let rssiList = value.RSSI
//            let rssiVariance = calVariance(buffer: rssiList, bufferMean: mean(of: rssiList))
//            let rssiStd = calStd(buffer: rssiList, bufferMean: mean(of: rssiList))
//            if (mean(of: rssiList) > -55) {
//                print(getLocalTimeString() + " , (BLE State) : id = \(key) // list = \(rssiList) // var = \(rssiVariance) // std = \(rssiStd)")
//            }
//        }
//        print(getLocalTimeString() + " , (BLE State) : timer --------------------------------")
        
        print(getLocalTimeString() + " , (BLE Count) : All Count = \(BLE.Info.keys.count)")
        for (category, counts) in categoryCountDict {
            let deviceCountData = DeviceCountData(category: category, fixedCount: counts[0], staticCount: counts[1], dynamicCount: counts[2])
            scanDeviceCountDataList.append(deviceCountData)
        }
        
        
        let predefinedOrder = FILTER_ORDER
        scanDeviceCountDataList.sort { predefinedOrder.firstIndex(of: $0.category)! < predefinedOrder.firstIndex(of: $1.category)! }
        
        for item in scanDeviceCountDataList {
            print(getLocalTimeString() + " , (BLE Count) : category = \(item.category) // d_count = \(item.dynamicCount) // s_count = \(item.staticCount)")
        }
        
        print(getLocalTimeString() + " , (BLE Scan) : timer --------------------------------")
        deviceCountDataList.accept(scanDeviceCountDataList)
        
        // Add
        for (category, counts) in categoryCountDict {
            if let info = DeviceCountInfo.Info[category] {
                // 기존에 UUID에 매칭된 정보가 있음
                let oldInfoTimeBuffer = info.timeBuffer
                let oldInfoFixedCount = info.fixedCount
                let oldInfoStaticCount = info.staticCount
                let oldInfoDynamic = info.dynamicCount
                let newInfo = CountInfo(timeBuffer: oldInfoTimeBuffer + [currentTime], fixedCount: oldInfoFixedCount + [counts[0]], staticCount: oldInfoStaticCount + [counts[1]], dynamicCount: oldInfoDynamic + [counts[2]])
                DeviceCountInfo.Info.updateValue(newInfo, forKey: category)
            } else {
                // UUID에 매칭된 정보가 없음
                let initialInfo = CountInfo(timeBuffer: [currentTime], fixedCount: [counts[0]], staticCount: [counts[1]], dynamicCount: [counts[2]])
                DeviceCountInfo.Info.updateValue(initialInfo, forKey: category)
            }
            self.DeviceCountInfo = trimDeviceCountInfo(input: DeviceCountInfo, currentTime: currentTime, trimmingTime: TRIMMING_TIME_FOR_STATE)
        }
//        print(getLocalTimeString() + " , (BLE Count) : DeviceCountInfo = \(DeviceCountInfo)")
        
        scanDeviceCountDataList = makeDeviceCountDataList(deviceCountBuffer: self.DeviceCountInfo)
//        print(getLocalTimeString() + " , (BLE Count) : scanDeviceCountDataList = \(scanDeviceCountDataList)")
        deviceCountDataList.accept(scanDeviceCountDataList)
    }
    
    private func convertToValidCategory(category: String) -> String {
        var validCategoryName: String = category
        
        if !FILTER_ORDER.contains(validCategoryName) {
            validCategoryName = FILTER_ORDER[FILTER_ORDER.count-1]
        }
        
        return validCategoryName
    }
    
    private func decideDeviceState(deviceType: DeviceType, rssiList: [Int]) -> DeviceState {
        if deviceType == .ELECTRONICS {
            return .FIXED_STATE
        } else {
//            let rssiVariance = calVariance(buffer: rssiList, bufferMean: mean(of: rssiList))
            let rssiStd = calStd(buffer: rssiList, bufferMean: mean(of: rssiList))
            
            if rssiStd <= STATIC_THRESHOLD {
                return .STATIC_STATE
            } else {
                return .DYNAMIC_STATE
            }
        }
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
        print("Filter Distance : \(value) m")
    }
    
    private func trimDeviceCountInfo(input: DeviceCountBuffer, currentTime: Int, trimmingTime: Int) -> DeviceCountBuffer {
        var result = DeviceCountBuffer(Info: [String: CountInfo]())
        for (key, value) in input.Info {
            var newTimeBuffer = [Int]()
            var newFixedCount = [Int]()
            var newStaticCount = [Int]()
            var newDynamicCount = [Int]()
            
            let oldTimeBuffer = value.timeBuffer
            let oldFixedCount = value.fixedCount
            let oldStaticCount = value.staticCount
            let oldDynamicCountt = value.dynamicCount
            
            for i in 0..<oldTimeBuffer.count {
                let eachTime = oldTimeBuffer[i]
                if currentTime-eachTime <= trimmingTime {
                    newTimeBuffer.append(eachTime)
                    newFixedCount.append(oldFixedCount[i])
                    newStaticCount.append(oldStaticCount[i])
                    newDynamicCount.append(oldDynamicCountt[i])
                }
            }
            
            if newTimeBuffer.isEmpty {
                result.Info.removeValue(forKey: key)
            } else {
                let newInfo = CountInfo(timeBuffer: newTimeBuffer, fixedCount: newFixedCount, staticCount: newStaticCount, dynamicCount: newDynamicCount)
                result.Info.updateValue(newInfo, forKey: key)
            }
        }
        
        return result
    }
    
    private func makeDeviceCountDataList(deviceCountBuffer: DeviceCountBuffer) -> [DeviceCountData] {
        var scanDeviceCountDataList = [DeviceCountData]()
        
        for (key, value) in deviceCountBuffer.Info {
            let category = key
            let fixedCount = value.fixedCount.filter({ $0 != 0 }).min() ?? 0
            let staticCount = value.staticCount.filter({ $0 != 0 }).min() ?? 0
            let dynamicCount = value.dynamicCount.filter({ $0 != 0 }).min() ?? 0
            
            let deviceCountData = DeviceCountData(category: category, fixedCount: fixedCount, staticCount: staticCount, dynamicCount: dynamicCount)
            if category == "Etc" {
                print(getLocalTimeString() + ", Device Count (fixed) : list = \(value.fixedCount) // min = \(fixedCount)")
                print(getLocalTimeString() + ", Device Count (static) : list = \(value.staticCount) // min = \(staticCount)")
                print(getLocalTimeString() + ", Device Count (dynamic) : list = \(value.dynamicCount) // min = \(dynamicCount)")
            }
            
            scanDeviceCountDataList.append(deviceCountData)
        }
        
        let predefinedOrder = FILTER_ORDER
        scanDeviceCountDataList.sort { predefinedOrder.firstIndex(of: $0.category)! < predefinedOrder.firstIndex(of: $1.category)! }
        
        return scanDeviceCountDataList
    }
}
