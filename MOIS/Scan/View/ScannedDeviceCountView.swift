import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class ScannedDeviceCountView: UIView {
    
    let deviceCountDataRelay = BehaviorRelay<[DeviceCountData]>(value: [])
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
        bindData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var headerView: ScannedDeviceCountSectionHeaderView = {
        let view = ScannedDeviceCountSectionHeaderView()
//        view.backgroundColor = .blue
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = .zero  // Ensure the header is not part of the collection view
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ScannedDeviceCountDataCell.self, forCellWithReuseIdentifier: ScannedDeviceCountDataCell.identifier)
        
        return collectionView
    }()
    
    private func bindData() {
        deviceCountDataRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension ScannedDeviceCountView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}

extension ScannedDeviceCountView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deviceCountDataRelay.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScannedDeviceCountDataCell.identifier, for: indexPath) as? ScannedDeviceCountDataCell else {
            return UICollectionViewCell()
        }
        
        let deviceCountData = deviceCountDataRelay.value[indexPath.row]
        cell.configure(with: deviceCountData)

        return cell
    }
}

private extension ScannedDeviceCountView {
    func setupLayout() {
        addSubview(headerView)
        addSubview(collectionView)
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(30) // Set the height of the header view
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
