import CoreBluetooth

enum TrimBleDataError: Error {
    case invalidInput
    case noValidData
}

let NRF_UUID_SERVICE = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
let NRF_UUID_CHAR_READ = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
let NRF_UUID_CHAR_WRITE = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
let NI_UUID_SERVICE = "00001530-1212-efde-1523-785feabcd123"
let UUIDService = CBUUID(string: NRF_UUID_SERVICE)
let UUIDRead = CBUUID(string: NRF_UUID_CHAR_READ)
let UUIDWrite = CBUUID(string: NRF_UUID_CHAR_WRITE)
let NIService = CBUUID(string: NI_UUID_SERVICE)

let TJLABS_UUID: String = "0000FEAA-0000-1000-8000-00805f9b34fb"

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BLEManager()
    let TRIMMING_TIME: Int = 5 * 1000
    
    var BLE = BLEDevices(Info: [String: BLEInfo]())
    var centralManager: CBCentralManager!
    var peripherals = [CBPeripheral]()
    var discoveredPeripheral: CBPeripheral!
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    var readCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?
    
    var connected: Bool = false
    var isScanning: Bool = false
    var bluetoothReady: Bool = false
    
    // TJLABS
    let oneServiceUUID = CBUUID(string: TJLABS_UUID)
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    var isBluetoothPermissionGranted: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .allowedAlways
        }
        return true
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            self.bluetoothReady = false
        case .poweredOn:
            self.bluetoothReady = true
            if !self.centralManager.isScanning {
                startScan()
            }
        case .resetting, .unauthorized, .unknown, .unsupported:
            self.bluetoothReady = false
        @unknown default:
            print("CBCentralManager: unknown state")
        }
    }
    
    func startScan() {
        if centralManager.isScanning {
            stopScan()
        }
        
        if bluetoothReady {
            self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)])
            self.isScanning = true
            print(getLocalTimeString() + " , (BLE Scan) : Started scanning for BLE devices")
        }
    }
    
    func stopScan() {
        self.centralManager.stopScan()
        self.isScanning = false
        print(getLocalTimeString() + " , (BLE Scan) : Stopped scanning for BLE devices")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if discoveredPeripherals[peripheral.identifier] == nil {
            discoveredPeripherals[peripheral.identifier] = peripheral
        }
        
        var localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if localName == nil {
            localName = peripheral.name
            if localName == nil {
                centralManager.connect(peripheral, options: nil)
            }
        }
        
        parseScannedData(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI, localName: localName)
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
//        print(getLocalTimeString() + " , (BLE Scan) : peripheral = \(peripheral.name ?? "Unknown")")
        updatePeripheralName(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.connected = false
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.discoveredPeripheral = peripheral
        self.discoveredPeripheral.delegate = self
        self.connected = true
        peripheral.discoverServices([UUIDService])
        if let name = peripheral.name {
            updatePeripheralName(peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([UUIDRead, UUIDWrite], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        for characteristic in service.characteristics! {
            if characteristic.uuid == UUIDRead {
                readCharacteristic = characteristic
                if !characteristic.isNotifying {
                    peripheral.setNotifyValue(true, for: readCharacteristic!)
                }
            }
            if characteristic.uuid == UUIDWrite {
                writeCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }
        
        guard let value = characteristic.value else { return }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Error disconnecting from peripheral: \(error.localizedDescription)")
        }
        discoveredPeripherals.removeValue(forKey: peripheral.identifier)
    }
    
    func isConnected() -> Bool {
        return discoveredPeripheral != nil
    }
    
    func disconnectAll() {
        if let discoveredPeripheral = discoveredPeripheral {
            centralManager.cancelPeripheralConnection(discoveredPeripheral)
        }
    }
    
    private func parseScannedData(peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber, localName: String?) {
        discoveredPeripheral = peripheral
        
        let UUID = peripheral.identifier.uuidString
        
        var hasManufacturer = false
        var hasService = false
        
        let scannedDeviceName = localName ?? "Unknown"
        let scannedRSSI: Int = RSSI.intValue
        var scannedTxPower = -100
        if scannedRSSI != 127 {
            let scannedTime: Int = getCurrentTimeInMilliseconds()
            var scannedManufacturer: UInt16?
            var scannedServiceUUID: String = "Unknown"
            
            if let manufacturer = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
                hasManufacturer = true
                scannedManufacturer = manufacturer.firstTwoBytesAsUInt16
            }
            if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                for uuid in serviceUUIDs {
                    hasService = true
                    scannedServiceUUID = uuid.uuidString
                }
            }
            let companyName = getCompanyName(deviceName: scannedDeviceName, manufacturer: scannedManufacturer, serviceUUID: scannedServiceUUID)
            let categoryAndType = getCategoryAndType(deviceName: scannedDeviceName, companyName: companyName, serviceUUID: scannedServiceUUID)
            if let txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Int {
                scannedTxPower = txPower
            }
            
//            print(getLocalTimeString() + " (BLE Raw),\(scannedTime),\(UUID),\(scannedDeviceName),\(scannedRSSI),\(companyName),\(scannedServiceUUID),\(scannedTxPower)")
            if let info = BLE.Info[UUID] {
                let oldInfoRSSI = info.RSSI
                let oldInfoScannedTime = info.scannedTime
                var newInfo = info
                newInfo.RSSI = oldInfoRSSI + [scannedRSSI]
                newInfo.scannedTime = oldInfoScannedTime + [scannedTime]
                newInfo.localName = scannedDeviceName
                BLE.Info[UUID] = newInfo
            } else {
                let initialInfo = BLEInfo(pheripherl: peripheral, category: categoryAndType.0, type: categoryAndType.1, RSSI: [scannedRSSI], scannedTime: [scannedTime], localName: scannedDeviceName, manufacturer: companyName, serviceUUID: scannedServiceUUID)
                BLE.Info[UUID] = initialInfo
            }
            self.BLE = trimBLE(input: BLE, scannedTime: scannedTime, trimmingTime: TRIMMING_TIME)
        }
    }
    
    private func updatePeripheralName(_ peripheral: CBPeripheral) {
        if let localName = peripheral.name {
            if let info = BLE.Info[peripheral.identifier.uuidString] {
                var updatedInfo = info
                updatedInfo.localName = localName
                BLE.Info[peripheral.identifier.uuidString] = updatedInfo
            }
        }
    }
    
    private func getCompanyName(deviceName: String, manufacturer: UInt16?, serviceUUID: String) -> String {
        var companyName: String = ""
        
        let appleKeywords = ["Apple", "iPhone", "Mac", "Airpod"]
        if deviceName.contains("TJ-") {
            companyName = "TJLABS"
        } else if appleKeywords.contains(where: deviceName.contains) {
            companyName = "Apple"
        } else if deviceName.contains("Galaxy") {
            companyName = "Samsung"
        } else {
            let convertedManufacturer = convertManufacturer(manufacturer: manufacturer)
            if convertedManufacturer == "Unknown" {
                let convertedService = convertService(serviceUUID: serviceUUID)
                if convertedService == "Unknown" {
                    companyName = "Unknown"
                } else {
                    companyName = convertedService
                }
            } else {
                companyName = convertedManufacturer
            }
        }
        return companyName
    }
    
    private func getDeviceType(deviceName: String, manufacturer: UInt16?, serviceUUID: String) -> DeviceType {
        return .UNKNOWN
    }
    
    private func getCategoryAndType(deviceName: String, companyName: String, serviceUUID: String) -> (String, DeviceType) {
        var deviceCategory = "Etc"
        var deviceType: DeviceType = .UNKNOWN
        
        if companyName == "TJLABS" {
            deviceCategory = companyName
            deviceType = .ELECTRONICS
        } else if companyName == "Apple" {
            deviceCategory = companyName
            for item in appleMobile { if deviceName.contains(item) { deviceType = .SMART_PHONE } }
            for item in appleElectronics { if deviceName.contains(item) { deviceType = .ELECTRONICS } }
            for item in appleWearable { if deviceName.contains(item) { deviceType = .WEARABLE } }
        } else if companyName == "Samsung" {
            for item in samsungMobile {
                if deviceName.contains(item) {
                    deviceCategory = "Google"
                    deviceType = .SMART_PHONE
                }
            }
            for item in samsungElectronics { if deviceName.contains(item) { deviceType = .ELECTRONICS } }
            for item in samsungWearable { if deviceName.contains(item) { deviceType = .WEARABLE } }
        } else if companyName == "LG" {
            deviceCategory = companyName
        } else if companyName == "Google" {
            deviceCategory = companyName
        } else {
            for item in unknownElectronics { if deviceName.contains(item) { deviceType = .ELECTRONICS } }
        }
        
        return (deviceCategory, deviceType)
    }
    
    private func convertManufacturer(manufacturer: UInt16?) -> String {
        var convertedString: String = "Unknown"
        if let value = manufacturer {
            if let matchedCompany = companyIdentifiers[value] {
                convertedString = matchedCompany
            }
        }
        return convertedString
    }
    
    private func convertService(serviceUUID: String) -> String {
        var serviceString: String = "Unknown"
        if let value = hexStringToUInt16(hexString: serviceUUID) {
            if let matchedService = memberServices[value] {
                serviceString = matchedService
            }
        }
        return serviceString
    }
    
    public func trimBLE(input: BLEDevices, scannedTime: Int, trimmingTime: Int) -> BLEDevices {
        var result = BLEDevices(Info: [String: BLEInfo]())
        for (key, value) in input.Info {
            var newRSSI = [Int]()
            var newScannedTime = [Int]()
            
            let oldRSSI = value.RSSI
            let oldScannedTime = value.scannedTime
            for i in 0..<oldScannedTime.count {
                let eachTime = oldScannedTime[i]
                if scannedTime - eachTime <= trimmingTime {
                    newRSSI.append(oldRSSI[i])
                    newScannedTime.append(eachTime)
                }
            }
            
            if newRSSI.isEmpty {
                result.Info.removeValue(forKey: key)
            } else {
                let newInfo = BLEInfo(pheripherl: value.pheripherl, category: value.category, type: value.type, RSSI: newRSSI, scannedTime: newScannedTime, localName: value.localName, manufacturer: value.manufacturer, serviceUUID: value.serviceUUID)
                result.Info.updateValue(newInfo, forKey: key)
            }
        }
        
        return result
    }
    
    public func getBLE() -> BLEDevices {
        return self.BLE
    }
    
    public func convertCompanyToCategory(company: String) -> String {
        var category: String = "Etc"
        
        if company.contains("TJLABS") {
            category = "TJLABS"
        } else if company.contains("Samsung") {
            category = "Samsung"
        } else if company.contains("Apple") {
            category = "Apple"
        } else if company.contains("LG") {
            category = "LG"
        } else if company.contains("Google") {
            category = "Google"
        } else if company.contains("Microsoft") {
            category = "Microsoft"
        } else if company.contains("Sony") {
            category = "Sony"
        }
        
        return category
    }
    
    public func convertRSSItoDistance(RSSI: Int) -> Int {
        let A: Double = -40
        let n: Double = 3
        let valueForPow: Double = (A - Double(RSSI)) / (10 * n)
        let distance = pow(Double(10), valueForPow)
        
        return Int(distance)
    }
    
    public func convertForSlider(RSSI: Float) -> Float {
        let A: Float = -40
        let n: Float = 3
        let valueForPow: Float = (A - Float(RSSI)) / (10 * n)
        let distance: Float = pow(Float(10), valueForPow)
        
        return distance
    }
    
    public func convertDistanceToRSSI(distance: Float) -> Float {
        let A: Float = -40
        let n: Float = 3
        let valueForPow: Float = log10(distance)
        let RSSI: Float = A - (10 * n * valueForPow)
        
        return RSSI
    }
}
