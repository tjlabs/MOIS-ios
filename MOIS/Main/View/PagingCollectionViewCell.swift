import UIKit
import SnapKit

class PagingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PagingCollectionViewCell"
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 36.0, weight: .bold)
        label.textAlignment = .center
        label.backgroundColor = [.systemOrange, .systemMint, .systemBrown].randomElement()
        
        return label
    }()
    
    func setupView(title: String) {
        setupLayout()
        contentLabel.text = title
    }
}

private extension PagingCollectionViewCell {
    func setupLayout() {
        [
            contentLabel
        ].forEach { addSubview($0) }
        
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
