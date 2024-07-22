import CoreBluetooth

enum TrimBleDataError: Error {
    case invalidInput
    case noValidData
}

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BLEManager()
    let TRIMMING_TIME: Int = 5*1000
    
    var BLE = BLEDevices(Info: [String: BLEInfo]())
    var centralManager: CBCentralManager!
    var peripherals = [CBPeripheral]()
    var discoveredPeripheral: CBPeripheral?
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    var readCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?
    
    var isScanning: Bool = false
    var bluetoothReady: Bool = false
    
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
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if discoveredPeripherals[peripheral.identifier] == nil {
            discoveredPeripherals[peripheral.identifier] = peripheral
        }
        parseScannedData(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print(getLocalTimeString() + " , (BLE Scan) : peripheral = \(peripheral.name)")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.properties.contains(.write) {
                    writeCharacteristic = characteristic
                }
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
    
    private func parseScannedData(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let UUID = peripheral.identifier.uuidString
        
        var hasManufacturer: Bool = false
        var hasService: Bool = false
        
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let scannedDeviceName = localName ?? peripheral.name ?? "Unknown"
        let scannedRSSI: Int = RSSI.intValue
        if scannedRSSI != 127 {
            let scannedTime: Int = getCurrentTimeInMilliseconds()
            var scannedManufacturer: UInt16?
            var scannedServiceUUID: String = "Unknown"
            
            if let manufacturer = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
    //            print(getLocalTimeString() + " , (BLE Scan) : manufacturer = \(manufacturer.dataToHexString)")
                hasManufacturer = true
                scannedManufacturer = manufacturer.firstTwoBytesAsUInt16
            }
            if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                for uuid in serviceUUIDs {
    //                print(getLocalTimeString() + " , (BLE Scan) : Service UUID = \(uuid.uuidString)")
                    hasService = true
                    scannedServiceUUID = uuid.uuidString
                }
            }
            let companyName = getCompanyName(deviceName: scannedDeviceName, manufacturer: scannedManufacturer, serviceUUID: scannedServiceUUID)
    //        print(getLocalTimeString() + " , (BLE Scan) : UUID = \(UUID) // name = \(scannedDeviceName) // RSSI = \(scannedRSSI) // company = \(companyName)")
            if let info = BLE.Info[UUID] {
                // 기존에 UUID에 매칭된 정보가 있음
                let oldInfoRSSI = info.RSSI
                let oldInfoScannedTime = info.scannedTime
                let newInfo = BLEInfo(pheripherl: peripheral, type: "Unknown", RSSI: oldInfoRSSI + [scannedRSSI], scannedTime: oldInfoScannedTime + [scannedTime], localName: scannedDeviceName, manufacturer: companyName, serviceUUID: scannedServiceUUID)
                BLE.Info.updateValue(newInfo, forKey: UUID)
            } else {
                // UUID에 매칭된 정보가 없음
                let initialInfo = BLEInfo(pheripherl: peripheral, type: "Unknown", RSSI: [scannedRSSI], scannedTime: [scannedTime], localName: scannedDeviceName, manufacturer: companyName, serviceUUID: scannedServiceUUID)
                BLE.Info.updateValue(initialInfo, forKey: UUID)
            }
            self.BLE = trimBLE(input: BLE, scannedTime: scannedTime)
        }
    }
    
    private func getCompanyName(deviceName: String, manufacturer: UInt16?, serviceUUID: String) -> String {
        var companyName: String = ""
        
        // 1. Check Device Name
        let appleKeywords = ["Apple", "iPhone", "Mac", "Airpod"]
        if deviceName.contains("TJ-") {
            companyName = "TJLABS Corp."
        } else if appleKeywords.contains(where: deviceName.contains) {
            companyName = "Apple, Inc."
        } else if deviceName.contains("Galaxy") {
            companyName = "Samsung Electronics Co. Ltd."
        } else {
            // 2. Check Manufacturer
            let convertedManufacturer = convertManufacturer(manufacturer: manufacturer)
            if convertedManufacturer == "Unknown" {
                // 3. Check Service UUID
                let convertedService = convertService(serviceUUID: serviceUUID)
                if convertedService == "Unknown" {
//                    companyName = "Apple, Inc."
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
    
    private func convertManufacturer(manufacturer: UInt16?) -> String{
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
    
    private func trimBLE(input: BLEDevices, scannedTime: Int) -> BLEDevices {
        var result = BLEDevices(Info: [String: BLEInfo]())
        for (key, value) in input.Info {
            var newRSSI = [Int]()
            var newScannedTime = [Int]()
            
            let oldRSSI = value.RSSI
            let oldScannedTime = value.scannedTime
            for i in 0..<oldScannedTime.count {
                let eachTime = oldScannedTime[i]
                if scannedTime-eachTime <= TRIMMING_TIME {
                    newRSSI.append(oldRSSI[i])
                    newScannedTime.append(eachTime)
                }
            }
            
            if newRSSI.isEmpty {
                result.Info.removeValue(forKey: key)
            } else {
                let newInfo = BLEInfo(pheripherl: value.pheripherl, type: value.type, RSSI: newRSSI, scannedTime: newScannedTime, localName: value.localName, manufacturer: value.manufacturer, serviceUUID: value.serviceUUID)
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
        let valueForPow: Double = (A-Double(RSSI))/(10*n)
        let distance = pow(Double(10), valueForPow)

        return Int(distance)
    }
}
