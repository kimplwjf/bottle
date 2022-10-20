//
//  BOLoginVC.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/14.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit

private let buttonFrame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
private let buttonHeight = textFieldHeight
private let buttonHorizontalMargin = textFieldHorizontalMargin / 2
private let buttonImageDimension: CGFloat = 18
private let buttonVerticalMargin = (buttonHeight - buttonImageDimension) / 2
private let buttonWidth = (textFieldHorizontalMargin / 2) + buttonImageDimension
private let critterViewDimension: CGFloat = 160
private let critterViewFrame = CGRect(x: 0, y: 0, width: critterViewDimension, height: critterViewDimension)
private let critterViewTopMargin: CGFloat = 70
private let textFieldHeight: CGFloat = 37
private let textFieldHorizontalMargin: CGFloat = 16.5
private let textFieldSpacing: CGFloat = 22
private let textFieldTopMargin: CGFloat = 38.8
private let textFieldWidth: CGFloat = 206

final class BOLoginVC: BaseVC, UITextFieldDelegate {
    
    private let critterView = CritterView(frame: critterViewFrame)
    private var waveView: BKWaveView!
    
    private lazy var emailTextField: UITextField = {
        let textField = createTextField(text: "账号长度大于5个字符")
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = createTextField(text: "密码长度大于5个字符")
        textField.isSecureTextEntry = true
        textField.returnKeyType = .go
        textField.rightView = showHidePasswordButton
        showHidePasswordButton.isHidden = true
        return textField
    }()
    
    private lazy var showHidePasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        button.frame = buttonFrame
        button.tintColor = .text
        button.setImage(#imageLiteral(resourceName: "Password-hide"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "Password-show"), for: .selected)
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginBtn: UIButton = {
        let btn = self.bk_addButton(type: .custom, title: "立即登录", font: .systemFont(ofSize: 18, weight: .medium), bgColor: .white, titleColor: .dark, radius: 22)
        btn.bk_addCornerBorder(radius: 22, borderWidth: 0.1, borderColor: .clear)
        btn.bk_addTarget { [weak self] sender in
            self?.validLogin()
        }
        return btn
    }()
    
    private let notificationCenter: NotificationCenter = .default
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bk_setLeftBarButtonItem(isHidden: true)
        DB.startSetup()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let deadlineTime = DispatchTime.now() + .milliseconds(100)
        
        if textField == emailTextField {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) { // 🎩✨ Magic to ensure animation starts
                let fractionComplete = self.fractionComplete(for: textField)
                self.critterView.startHeadRotation(startAt: fractionComplete)
                self.passwordDidResignAsFirstResponder()
            }
        } else if textField == passwordTextField {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) { // 🎩✨ Magic to ensure animation starts
                self.critterView.isShy = true
                self.showHidePasswordButton.isHidden = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
            passwordDidResignAsFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            critterView.stopHeadRotation()
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard !critterView.isActiveStartAnimating, textField == emailTextField else { return }
        
        let fractionComplete = self.fractionComplete(for: textField)
        critterView.updateHeadRotation(to: fractionComplete)
        
        if let text = textField.text {
            critterView.isEcstatic = text.contains("@")
        }
    }
    
    // MARK: - Private
    private func validLogin() {
        let email = emailTextField.text ?? ""
        let pwd = passwordTextField.text ?? ""
        if let model: DBUserModel = DB.shared.query(table: .user, where: DBUserModel.Properties.email == email && DBUserModel.Properties.pwd == pwd) {
            if model._state == .normal {
                self.bk_showLoading()
                BKTaskUtil.delay(0.5) {
                    self.bk_hideLoading()
                    XMApp.kUserModel = model
                    App.startEnterApp()
                }
            } else {
                BPM.showAlert(.warning, msg: "此账号已被注销!")
            }
        } else {
            if email.count > 5 && pwd.count > 5 {
                self.bk_showLoading()
                BKTaskUtil.delay(0.5) {
                    self.bk_hideLoading()
                    let random = Int.random6Digit()
                    let model = DBUserModel()
                    model.email = email
                    model.pwd = pwd
                    model.nickname = "漂友\(random)"
                    DB.shared.insert(object: model, intoTable: .user)
                    model.userId = Int(model.lastInsertedRowID)
                    XMApp.kUserModel = model
                    App.startEnterApp()
                }
            } else {
                BPM.showAlert(.warning, msg: .inputError)
            }
        }
    }
    
    private func setUpView() {
        naviBarBarTintColor = .dark
        view.backgroundColor = .dark
        
        waveView = BKWaveView(frame: kCGRect(0, -kNavigationBarHeight, kScreenWidth, kScreenHeight))
        waveView.updateWithConfigure { configure in
            configure.color = .light
            configure.y = kScreenHeight-kTabBarHeight
            configure.upSpeed = 0.1
        }
        view.addSubview(waveView)
        
        view.addSubview(critterView)
        setUpCritterViewConstraints()
        
        view.addSubview(emailTextField)
        setUpEmailTextFieldConstraints()
        
        view.addSubview(passwordTextField)
        setUpPasswordTextFieldConstraints()
        
        let title = self.bk_addLabel(text: "登录/注册", font: .systemFont(ofSize: 30, weight: .medium), bgColor: .clear, textColor: .lightWhiteDark27)
        view.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerX.equalTo(critterView)
            make.bottom.equalTo(critterView.snp.top).offset(-20)
        }
        
        view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { make in
            make.centerX.equalTo(passwordTextField)
            make.top.equalTo(passwordTextField.snp.bottom).offset(50)
            make.size.equalTo(CGSize(width: kScreenWidth*0.5, height: 44))
        }
        
        setUpGestures()
        setUpNotification()
        
        debug_setUpDebugUI()
    }
    
    private func setUpCritterViewConstraints() {
        critterView.translatesAutoresizingMaskIntoConstraints = false
        critterView.heightAnchor.constraint(equalToConstant: critterViewDimension).isActive = true
        critterView.widthAnchor.constraint(equalTo: critterView.heightAnchor).isActive = true
        critterView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        critterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: critterViewTopMargin).isActive = true
    }
    
    private func setUpEmailTextFieldConstraints() {
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: critterView.bottomAnchor, constant: textFieldTopMargin).isActive = true
    }
    
    private func setUpPasswordTextFieldConstraints() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
        passwordTextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: textFieldSpacing).isActive = true
    }
    
    private func fractionComplete(for textField: UITextField) -> Float {
        guard let text = textField.text, let font = textField.font else { return 0 }
        let textFieldWidth = textField.bounds.width - (2 * textFieldHorizontalMargin)
        return min(Float(text.size(withAttributes: [NSAttributedString.Key.font : font]).width / textFieldWidth), 1)
    }
    
    private func stopHeadRotation() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        critterView.stopHeadRotation()
        passwordDidResignAsFirstResponder()
    }
    
    private func passwordDidResignAsFirstResponder() {
        critterView.isPeeking = false
        critterView.isShy = false
        showHidePasswordButton.isHidden = true
        showHidePasswordButton.isSelected = false
        passwordTextField.isSecureTextEntry = true
    }
    
    private func createTextField(text: String) -> UITextField {
        let view = UITextField(frame: CGRect(x: 0, y: 0, width: textFieldWidth, height: textFieldHeight))
        view.backgroundColor = .white
        view.layer.cornerRadius = 4.07
        view.tintColor = .dark
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.spellCheckingType = .no
        view.delegate = self
        view.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let frame = CGRect(x: 0, y: 0, width: textFieldHorizontalMargin, height: textFieldHeight)
        view.leftView = UIView(frame: frame)
        view.leftViewMode = .always
        
        view.rightView = UIView(frame: frame)
        view.rightViewMode = .always
        
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        view.textColor = .text
        
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.disabledText,
            .font : view.font!
        ]
        
        view.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
        return view
    }
    
    // MARK: - Gestures
    private func setUpGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        stopHeadRotation()
    }
    
    // MARK: - Actions
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        let isPasswordVisible = sender.isSelected
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        critterView.isPeeking = isPasswordVisible
        
        // 🎩✨ Magic to fix cursor position when toggling password visibility
        if let textRange = passwordTextField.textRange(from: passwordTextField.beginningOfDocument, to: passwordTextField.endOfDocument), let password = passwordTextField.text {
            passwordTextField.replace(textRange, withText: password)
        }
    }
    
    // MARK: - Notifications
    private func setUpNotification() {
        notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func applicationDidEnterBackground() {
        stopHeadRotation()
    }
    
    // MARK: - Debug Mode
    private let isDebugMode = false
    
    private lazy var dubug_activeAnimationSlider = UISlider()
    
    private func debug_setUpDebugUI() {
        guard isDebugMode else { return }
        
        let animateButton = UIButton(type: .system)
        animateButton.setTitle("Activate", for: .normal)
        animateButton.setTitleColor(.white, for: .normal)
        animateButton.addTarget(self, action: #selector(debug_activeAnimation), for: .touchUpInside)
        
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Neutral", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.addTarget(self, action: #selector(debug_neutralAnimation), for: .touchUpInside)
        
        let validateButton = UIButton(type: .system)
        validateButton.setTitle("Ecstatic", for: .normal)
        validateButton.setTitleColor(.white, for: .normal)
        validateButton.addTarget(self, action: #selector(debug_ecstaticAnimation), for: .touchUpInside)
        
        dubug_activeAnimationSlider.tintColor = .light
        dubug_activeAnimationSlider.isEnabled = false
        dubug_activeAnimationSlider.addTarget(self, action: #selector(debug_activeAnimationSliderValueChanged(sender:)), for: .valueChanged)
        
        let stackView = UIStackView(
            arrangedSubviews:
            [
                animateButton,
                resetButton,
                validateButton,
                dubug_activeAnimationSlider
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 5
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc private func debug_activeAnimation() {
        critterView.startHeadRotation(startAt: dubug_activeAnimationSlider.value)
        dubug_activeAnimationSlider.isEnabled = true
    }
    
    @objc private func debug_neutralAnimation() {
        stopHeadRotation()
        dubug_activeAnimationSlider.isEnabled = false
    }
    
    @objc private func debug_ecstaticAnimation() {
        critterView.isEcstatic.toggle()
    }
    
    @objc private func debug_activeAnimationSliderValueChanged(sender: UISlider) {
        critterView.updateHeadRotation(to: sender.value)
    }
    
}
