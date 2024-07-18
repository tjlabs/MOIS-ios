import UIKit
import SnapKit

class MainViewController: UIViewController {
    private let categoryTitleList = [ "Scan", "Flow", "Knock" ]
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "MOIS"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var pagingTabBar = PagingTabBar(categoryTitleList: categoryTitleList)
    private lazy var pagingView = PagingView(categoryTitleList: categoryTitleList, pagingTabBar: pagingTabBar)
    
    private lazy var separatorView: UIView = {
            let view = UIView()
            view.backgroundColor = .black
            return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    

}

private extension MainViewController {
    func setupLayout() {
        [
            titleLabel,
            separatorView,
            pagingTabBar,
            pagingView
        ].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-30)
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-32)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        separatorView.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-2)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(2)
        }
        
        pagingTabBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(pagingTabBar.cellHeight)
        }
        pagingView.snp.makeConstraints { make in
            make.top.equalTo(pagingTabBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
