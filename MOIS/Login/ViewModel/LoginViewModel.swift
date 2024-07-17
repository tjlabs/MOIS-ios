
import Foundation

import RxCocoa
import RxSwift

final class LoginViewModel {
    
    let emailRelay = BehaviorRelay<String>(value: "이메일을 입력해주세요")
    let passwordRelay = BehaviorRelay<String>(value: "비밀번호를 입력해주세요")
    
    var isValid: Observable<Bool> {
        return Observable
            .combineLatest(emailRelay, passwordRelay)
            .map { email, password in
                print("Email : \(email), Password : \(password)")
                return !email.isEmpty && email.contains("@") && email.contains(".") && password.count > 0 && !password.isEmpty
            }
    }

    struct Input {
        let emailText: ControlProperty<String?>
        let passwordText: ControlProperty<String?>
        let loginTap: ControlEvent<Void>
    }
    
    struct Output {
        // relay 초기값 .. ?
        let emailRelay: BehaviorRelay<String>
        let passwordRelay: BehaviorRelay<String>
        
        // 텍스트필드 입력값
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        
        // 버튼 탭
        let loginTap: ControlEvent<Void>
        
        // 유효성 판단
        let isValid: Driver<Bool>
    }
    
    func transform(from input: Input) -> Output {
        let emailText = input.emailText.orEmpty
        let passwordText = input.passwordText.orEmpty
        
        let isValid = isValid.asDriver(onErrorJustReturn: false)
        
        return Output(emailRelay: emailRelay,
                      passwordRelay: passwordRelay,
                      emailText: emailText,
                      passwordText: passwordText,
                      loginTap: input.loginTap,
                      isValid: isValid)
    }
}
