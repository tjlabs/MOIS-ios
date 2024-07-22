
import Foundation
import UIKit

import RxSwift
import RxCocoa
import SnapKit

class ScanView: UIView {
    
    let filterDeviceInfo = FilterDeviceInfo(opened: false, title: "Device Filter", manufacuterers: [
                            Manufacturer(name: "Apple"),
                            Manufacturer(name: "Google"),
                            Manufacturer(name: "Samsung"),
                            Manufacturer(name: "TJLABS"),
                            Manufacturer(name: "Etc")],
                            rssi: RSSI(),
                            distance: Distance())
    
    private lazy var filterDeviceView = FilterDeviceView(filterDeviceInfo: filterDeviceInfo)
    private lazy var separatorViewForInfo: UIView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            return view
    }()
    private lazy var deviceInfoView = ScannedDeviceInfoView()
    private lazy var separatorViewForCount: UIView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            return view
    }()
    
    let deviceScanDataRelay = BehaviorRelay<[DeviceScanData]>(value: [])
    let deviceCountDataRelay = BehaviorRelay<[DeviceCountData]>(value: [])
    private lazy var deviceCountView = ScannedDeviceCountView()
    
    private let viewModel = ScanViewModel()
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
        bindViewModel()
        viewModel.setFilterModel(filterDeviceInfo: filterDeviceInfo)
        filterDeviceView.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(filterDeviceView)
        addSubview(separatorViewForInfo)
        addSubview(deviceInfoView)
        
        addSubview(separatorViewForCount)
        addSubview(deviceCountView)
        
        filterDeviceView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview()
            filterViewHeightConstraint = make.height.equalTo(36).constraint
        }
        
        separatorViewForInfo.snp.makeConstraints { make in
            make.top.equalTo(filterDeviceView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1) // Height of the separator line
        }
        
        deviceCountView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
//            make.bottom.equalToSuperview().offset(-10)
        }
        
        deviceInfoView.snp.makeConstraints { make in
            make.top.equalTo(separatorViewForInfo.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(separatorViewForCount.snp.top)
        }
        
        separatorViewForCount.snp.makeConstraints { make in
            make.bottom.equalTo(deviceCountView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func bindFilterView() {
        filterDeviceView.sectionExpandedRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isExpanded in
                guard let self = self else { return }
                let contentHeight = self.filterDeviceView.contentHeight
                self.filterViewHeightConstraint?.update(offset: isExpanded ? contentHeight : 36)
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.deviceScanDataList
            .observe(on: MainScheduler.instance)
            .bind(to: deviceInfoView.deviceScanDataRelay)
            .disposed(by: disposeBag)
        
        viewModel.deviceCountDataList
            .observe(on: MainScheduler.instance)
            .bind(to: deviceCountView.deviceCountDataRelay)
            .disposed(by: disposeBag)
    }
}
