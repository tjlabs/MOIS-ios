import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Then

protocol BaseViewAttribute {
    func configureHierarchy()
    func setAttribute()
    func bind()
}

final class LoginView: UIView {
    
    // MARK: - UI Property
    
    private var emailTextField = UITextField().then {
        $0.borderStyle = .roundedRect
    }
    
    private var passwordTextField = UITextField().then {
        $0.borderStyle = .roundedRect
    }
    
    private var loginButton = UIButton().then {
        $0.backgroundColor = .systemPink
        $0.setTitle("로그인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    // MARK: - Property
    
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        setAttribute()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureHierarchy()
        setAttribute()
        bind()
    }
}

extension LoginView: BaseViewAttribute {
    func configureHierarchy() {
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        
        emailTextField.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(10)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
    }
    
    func setAttribute() {
        backgroundColor = .white
    }
    
    func bind() {
        let input = LoginViewModel.Input(emailText: emailTextField.rx.text,
                                         passwordText: passwordTextField.rx.text,
                                         loginTap: loginButton.rx.tap)
        
        let output = viewModel.transform(from: input)
        
        output.emailRelay
            .bind(to: emailTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.passwordRelay
            .bind(to: passwordTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.emailText
            .bind(to: viewModel.emailRelay)
            .disposed(by: disposeBag)
        
        output.passwordText
            .bind(to: viewModel.passwordRelay)
            .disposed(by: disposeBag)
        
        output.isValid
            .drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.isValid
            .map { $0 == true ? UIColor.systemPink : UIColor.systemGray4 }
            .drive(loginButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    private func presentAlert(_ title: String, _ message: String) {
        guard let viewController = parentViewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        viewController.present(alert, animated: true, completion: nil)
    }
}
