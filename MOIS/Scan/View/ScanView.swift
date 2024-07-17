
import Foundation
import UIKit

import RxSwift
import RxCocoa
import SnapKit

class ScanView: UIView {
    
    let filterList = [FilterCellData(opened: false, title: "Filter", sectionData: ["Cell1", "Cell2"]),
                      FilterCellData(opened: false, title: "Filter2", sectionData: ["Cell1", "Cell2"])]
    private lazy var filterView = FilterView(filterList: filterList)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()
}

private extension ScanView {
    func setupLayout() {
        addSubview(filterView)
        
        filterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
