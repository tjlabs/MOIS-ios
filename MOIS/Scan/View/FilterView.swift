import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class FilterView: UIView {
    // MARK: - Data
    private var filterInfo: FilterInfo
    private var isSectionExpanded: Bool = false
    
    init(filterInfo: FilterInfo) {
        self.filterInfo = filterInfo
        super.init(frame: .zero)
        setupLayout()
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
        collectionView.register(ManufacturerCell.self, forCellWithReuseIdentifier: ManufacturerCell.identifier)
        
        return collectionView
    }()
    
    private let disposeBag = DisposeBag()
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
        return isSectionExpanded ? filterInfo.manufacuterers.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ManufacturerCell.identifier, for: indexPath) as? ManufacturerCell else {
            return UICollectionViewCell()
        }
        
        let manufacturer = filterInfo.manufacuterers[indexPath.row]
        cell.configure(with: manufacturer)
        
        return cell
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
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}

private extension FilterView {
    func setupLayout() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
