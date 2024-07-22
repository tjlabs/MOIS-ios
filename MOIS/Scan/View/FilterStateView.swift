import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class FilterStateView: UIView {
    // MARK: - Data
    private var filterStateInfo: FilterStateInfo
    private var isSectionExpanded: Bool = false
    private let disposeBag = DisposeBag()
    let sectionExpandedRelay = BehaviorRelay<Bool>(value: false)
    
    var contentHeight: CGFloat {
        return collectionView.contentSize.height
    }
    
    var viewModel: ScanViewModel?
    
    init(filterStateInfo: FilterStateInfo) {
        self.filterStateInfo = filterStateInfo
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
        collectionView.register(FilterStateSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FilterStateSectionHeaderView.identifier)
        collectionView.register(FilterStateCell.self, forCellWithReuseIdentifier: FilterStateCell.identifier)
        
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

extension FilterStateView: UICollectionViewDelegateFlowLayout {
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

extension FilterStateView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSectionExpanded ? filterStateInfo.state.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let stateCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterStateCell.identifier, for: indexPath) as? FilterStateCell else {
            return UICollectionViewCell()
        }
        
        let stateData = filterStateInfo.state[indexPath.row]
        stateCell.configure(with: stateData)
        stateCell.switchValueChanged = { [weak self] isOn in
            guard let self = self else { return }
            self.filterStateInfo.state[indexPath.row].isChecked.isOn = isOn
            self.viewModel?.updateStateSwitchValue(state: stateData.type, isOn: isOn)
        }
        
        return stateCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FilterStateSectionHeaderView.identifier, for: indexPath) as? FilterStateSectionHeaderView else {
            return UICollectionReusableView()
        }
        
        headerView.titleLabel.text = filterStateInfo.title
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
