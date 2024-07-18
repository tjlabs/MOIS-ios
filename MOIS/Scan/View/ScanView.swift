
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
    private lazy var separatorView: UIView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            return view
    }()
    private lazy var deviceInfoView = DeviceInfoView()
    
    private let disposeBag = DisposeBag()
    private var filterViewHeightConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
        bindFilterView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(filterView)
        addSubview(separatorView)
        addSubview(deviceInfoView)
        
        filterView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview()
            filterViewHeightConstraint = make.height.equalTo(44).constraint
        }
        
        separatorView.snp.makeConstraints { make in
                    make.top.equalTo(filterView.snp.bottom)
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(1) // Height of the separator line
                }
        
        deviceInfoView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
//            make.bottom.equalToSuperview().offset(-10)
        }
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
