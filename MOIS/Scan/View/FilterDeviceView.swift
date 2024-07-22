import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class FilterDeviceView: UIView {
    // MARK: - Data
    private var filterDeviceInfo: FilterDeviceInfo
    private var isSectionExpanded: Bool = false
    private let disposeBag = DisposeBag()
    let sectionExpandedRelay = BehaviorRelay<Bool>(value: false)
    
    var contentHeight: CGFloat {
        return collectionView.contentSize.height
    }
    
    var viewModel: ScanViewModel?
    
    init(filterDeviceInfo: FilterDeviceInfo) {
        self.filterDeviceInfo = filterDeviceInfo
        super.init(frame: .zero)
        setupLayout()
        bindCollectionViewContentSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FilterDeviceSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FilterDeviceSectionHeaderView.identifier)
        collectionView.register(FilterDeviceManufacturerCell.self, forCellWithReuseIdentifier: FilterDeviceManufacturerCell.identifier)
        collectionView.register(FilterDeviceDistanceCell.self, forCellWithReuseIdentifier: FilterDeviceDistanceCell.identifier)
//        collectionView.register(FilterStateSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FilterStateSectionHeaderView.identifier)
        
        return collectionView
    }()
    
    private func setupLayout() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindCollectionViewContentSize() {
        collectionView.rx.observe(CGSize.self, "contentSize")
            .compactMap { $0?.height }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.isSectionExpanded {
                    self.sectionExpandedRelay.accept(true)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension FilterDeviceView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UIEdgeInsets, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension FilterDeviceView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSectionExpanded ? filterDeviceInfo.manufacuterers.count + 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < filterDeviceInfo.manufacuterers.count {
            guard let manufacturerCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDeviceManufacturerCell.identifier, for: indexPath) as? FilterDeviceManufacturerCell else {
                return UICollectionViewCell()
            }
            
            let manufacturer = filterDeviceInfo.manufacuterers[indexPath.row]
            manufacturerCell.configure(with: manufacturer)
            manufacturerCell.switchValueChanged = { [weak self] isOn in
                guard let self = self else { return }
                self.viewModel?.updateManufacturerSwitchValue(manufacturer: manufacturer.name, isOn: isOn)
            }
            
            return manufacturerCell
        } else {
            guard let distanceCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDeviceDistanceCell.identifier, for: indexPath) as? FilterDeviceDistanceCell else {
                return UICollectionViewCell()
            }
            distanceCell.configure(with: filterDeviceInfo.distance)
            distanceCell.sliderValueChanged = { [weak self] value in
                guard let self = self else { return }
                self.viewModel?.updateDistanceSliderValue(value: value)
            }
            
            return distanceCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FilterDeviceSectionHeaderView.identifier, for: indexPath) as? FilterDeviceSectionHeaderView else {
            return UICollectionReusableView()
        }
        
        headerView.titleLabel.text = filterDeviceInfo.title
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSection)))
        headerView.configure(isExpanded: isSectionExpanded)
        
        return headerView
    }
    
    @objc private func toggleSection() {
        isSectionExpanded.toggle()
        sectionExpandedRelay.accept(isSectionExpanded)
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}
