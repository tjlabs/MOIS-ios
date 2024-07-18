
import Foundation
import UIKit

import RxSwift
import RxCocoa
import SnapKit

class ScanView: UIView {
    
    let filterInfo = FilterInfo(opened: false, title: "Filter", manufacuterers: [
                            Manufacturer(name: "Apple"),
                            Manufacturer(name: "Google"),
                            Manufacturer(name: "Samsung"),
                            Manufacturer(name: "TJLABS"),
                            Manufacturer(name: "Etc")],
                            rssi: RSSI())
    
    private lazy var filterView = FilterView(filterInfo: filterInfo)
    private lazy var separatorViewForInfo: UIView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            return view
    }()
    private lazy var deviceInfoView = DeviceInfoView()
    private lazy var separatorViewForCount: UIView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            return view
    }()
    private lazy var deviceCountView = DeviceCountView()
    
    var deviceScanDataList = [DeviceScanData]()
    
    private let disposeBag = DisposeBag()
    private var filterViewHeightConstraint: Constraint?
    
    let locationManager = LocationManager()
    var bleTimer: DispatchSourceTimer?
    let BLE_TIMER_INTERVAL: TimeInterval = 2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
        bindFilterView()
        
        BLEManager.shared.startScan()
        startTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(filterView)
        addSubview(separatorViewForInfo)
        addSubview(deviceInfoView)
        
        addSubview(separatorViewForCount)
        addSubview(deviceCountView)
        
        filterView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview()
            filterViewHeightConstraint = make.height.equalTo(44).constraint
        }
        
        separatorViewForInfo.snp.makeConstraints { make in
            make.top.equalTo(filterView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1) // Height of the separator line
        }
        
        deviceCountView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
//            make.bottom.equalToSuperview().offset(-10)
        }
        
        deviceInfoView.snp.makeConstraints { make in
            make.top.equalTo(separatorViewForInfo.snp.bottom)
            make.leading.trailing.equalToSuperview()
//            make.bottom.equalTo(separatorViewForCount.snp.top)
            make.height.equalTo(200)
        }
        
        separatorViewForCount.snp.makeConstraints { make in
            make.bottom.equalTo(deviceCountView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
//        deviceInfoView.snp.makeConstraints { make in
//            make.top.equalTo(separatorViewForInfo.snp.bottom).offset(0)
////            make.bottom.equalTo(separatorViewForCount.snp.top)
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(200)
////            make.bottom.equalToSuperview().offset(-10)
//        }
        
        deviceInfoView.backgroundColor = .systemBrown
    }
    
    func startTimer() {
        if (self.bleTimer == nil) {
            let queueBLE = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".bleTimer")
            self.bleTimer = DispatchSource.makeTimerSource(queue: queueBLE)
            self.bleTimer!.schedule(deadline: .now(), repeating: BLE_TIMER_INTERVAL)
            self.bleTimer!.setEventHandler(handler: self.bleTimerUpdate)
            self.bleTimer!.resume()
        }
    }
    
    func stopTimer() {
        self.bleTimer?.cancel()
        self.bleTimer = nil
    }
    
    @objc func bleTimerUpdate() {
        makeDeviceScanDataList()
    }
    
    private func makeDeviceScanDataList() {
        var scanDataList = [DeviceScanData]()
        
        let BLE = BLEManager.shared.getBLE()
        for (key, value) in BLE.Info {
            let rssiValue = mean(of: value.RSSI)
//            print(getLocalTimeString() + " , (BLE Scan) : UUID = \(key) // company = \(value.manufacturer) // RSSI = \(rssiValue)")
            
            let category = BLEManager.shared.convertCompanyToCategory(company: value.manufacturer)
            let distance = BLEManager.shared.convertRSSItoDistance(RSSI: rssiValue)
            let scanData = DeviceScanData(state: .STATIC_STATE, category: category, rssi: rssiValue, distance: distance)
            scanDataList.append(scanData)
            print(getLocalTimeString() + " , (BLE Scan) : scanData = \(scanData)")
        }
        print(getLocalTimeString() + " , (BLE Scan) : timer --------------------------------")
        self.deviceScanDataList = scanDataList
    }
    
    private func bindFilterView() {
        filterView.sectionExpandedRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isExpanded in
                guard let self = self else { return }
                let contentHeight = self.filterView.contentHeight
                self.filterViewHeightConstraint?.update(offset: isExpanded ? contentHeight : 44)
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}
