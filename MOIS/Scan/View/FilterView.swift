import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class FilterView: UIView {
    // MARK: - Data
    private var filterInfo: FilterInfo
    private var isSectionExpanded: Bool = false
    
    private let disposeBag = DisposeBag()
    let sectionExpandedRelay = BehaviorRelay<Bool>(value: false)
    
    var contentHeight: CGFloat {
        return collectionView.contentSize.height
    }
    
    init(filterInfo: FilterInfo) {
        self.filterInfo = filterInfo
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
        collectionView.register(FilterSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FilterSectionHeaderView.identifier)
        collectionView.register(FilterManufacturerCell.self, forCellWithReuseIdentifier: FilterManufacturerCell.identifier)
        collectionView.register(FilterRSSICell.self, forCellWithReuseIdentifier: FilterRSSICell.identifier)
        
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

extension FilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension FilterView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSectionExpanded ? filterInfo.manufacuterers.count+1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterManufacturerCell.identifier, for: indexPath) as? FilterManufacturerCell else {
//            return UICollectionViewCell()
//        }
//        
//        let manufacturer = filterInfo.manufacuterers[indexPath.row]
//        cell.configure(with: manufacturer)
//        
//        return cell
        
        if indexPath.row < filterInfo.manufacuterers.count {
            guard let manufacturerCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterManufacturerCell.identifier, for: indexPath) as? FilterManufacturerCell else {
                return UICollectionViewCell()
            }
            
            let manufacturer = filterInfo.manufacuterers[indexPath.row]
            manufacturerCell.configure(with: manufacturer)
            
            return manufacturerCell
        } else {
            guard let rssiCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterRSSICell.identifier, for: indexPath) as? FilterRSSICell else {
                return UICollectionViewCell()
            }
            rssiCell.configure(with: filterInfo.rssi)
            
            return rssiCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FilterSectionHeaderView.identifier, for: indexPath) as? FilterSectionHeaderView else {
            return UICollectionReusableView()
        }
        
        headerView.titleLabel.text = filterInfo.title
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
