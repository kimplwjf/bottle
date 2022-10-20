//
//  BOMineVC.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/17.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit

class BOMineVC: BaseVC {
    
    override var backBarButtonItemHidden: Bool {
        return true
    }
    
    let color1: CGColor = UIColor(red: 209/255, green: 107/255, blue: 165/255, alpha: 1).cgColor
    let color2: CGColor = UIColor(red: 134/255, green: 168/255, blue: 231/255, alpha: 1).cgColor
    let color3: CGColor = UIColor(red: 95/255, green: 251/255, blue: 241/255, alpha: 1).cgColor
    
    let gradient: CAGradientLayer = CAGradientLayer()
    var gradientColorSet: [[CGColor]] = []
    var colorIndex: Int = 0
    
    private var waveView: BKWaveView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviBarBackgroundAlpha = 0
        self.setupGradient()
        self.animateGradient()
        
        self.navigationItem.titleView = titleView
        titleView.addSubview(settingBtn)
        settingBtn.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.centerY.equalToSuperview()
            make.right.equalTo(-8)
        }
        
        view.addSubviews([bgView, avatarImgView, sexImgView])
        bgView.snp.makeConstraints { make in
            make.top.equalTo(kNavigationBarHeight*4)
            make.left.bottom.right.equalToSuperview()
            make.width.equalTo(kScreenWidth)
        }
        
        avatarImgView.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.top.equalTo(bgView.snp.top).offset(-40)
            make.centerX.equalTo(bgView)
        }
        
        sexImgView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.bottom.right.equalTo(avatarImgView)
        }
        
        waveView = BKWaveView(frame: kCGRect(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight*4))
        waveView.updateWithConfigure { configure in
            configure.color = .light
            configure.y = kNavigationBarHeight*5
            configure.upSpeed = 0.1
        }
        bgView.addSubview(waveView)
        bgView.addSubviews([nicknameLabel, addressLabel])
        
        nicknameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarImgView.snp.bottom).offset(25)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nicknameLabel.snp.bottom).offset(7)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DelayStartupManager.startupEventsOnDidAppearAppContent()
        nicknameLabel.text = XMApp.kNickname
        let avatarPath = BKFilePathUtil.setupFilePath(directory: .documents, name: SANDBOX.File.Avatar).appendingPathComponent("avatar_\(XMApp.kUserId)").path
        if BKFileUtil.exists(filePath: avatarPath) {
            guard let data = BKFileUtil.readFile(filePath: avatarPath), let image = UIImage(data: data) else { return }
            avatarImgView.image = image
        }
        addressLabel.text = "\(XMApp.kUserModel?.province ?? "") \(XMApp.kUserModel?.city ?? "") \(XMApp.kUserModel?.area ?? "")"
    }
    
    // MARK: - lazy
    private lazy var titleView: CustomTitleView = {
        let view = CustomTitleView(frame: kCGRect(0, 0, kScreenWidth, 44))
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var settingBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.System.icon_setting, for: .normal)
        btn.bk_addTarget { [unowned self] (sender) in
            let vc = BOSettingVC()
            self.navigationController?.pushViewController(vc)
        }
        return btn
    }()
    
    private lazy var bgView: UIView = {
        let view = UIView(color: .lightWhiteDark27)
        return view
    }()
    
    private lazy var avatarImgView: UIImageView = {
        let iv = UIImageView(image: LOGO.APPICON)
        iv.bk_addCornerBorder(radius: 100/2, borderWidth: 4.0, borderColor: .lightWhiteDark27)
        iv.whenTap { tap in
            PhotoBrowser.pickerSingleImage { [weak self] photos in
                guard let photo = photos.first else { return }
                self?.avatarImgView.image = photo.image
                BKFileUtil.saveImageToFile(image: photo.image, folderName: SANDBOX.File.Avatar, fileName: "avatar_\(XMApp.kUserId)")
            }
        }
        return iv
    }()
    
    private lazy var sexImgView: UIImageView = {
        let sex = SexType(rawValue: XMApp.kSex ?? 1) ?? .man
        let iv = UIImageView(image: UIImage(named: sex.style.icon))
        iv.bk_addCornerBorder(radius: 24/2, borderWidth: 2, borderColor: .lightWhiteDark27)
        return iv
    }()
    
    private lazy var nicknameLabel = self.bk_addLabel(text: XMApp.kNickname, font: .systemFont(ofSize: 24, weight: .semibold), bgColor: .clear, textColor: .lightBlack51DarkLight230)
    
    private lazy var addressLabel = self.bk_addLabel(font: .systemFont(ofSize: 14), bgColor: .clear, textColor: XMColor.gray153)
    
}

// MARK: - Private
extension BOMineVC {
    
    private func setupGradient() {
        gradientColorSet = [
            [color1, color2],
            [color2, color3],
            [color3, color1]
        ]
        
        gradient.frame = kCGRect(0, -kNavigationBarHeight, view.bounds.width, view.bounds.height)
        gradient.colors = gradientColorSet[colorIndex]
        
        view.layer.addSublayer(gradient)
    }
    
    private func animateGradient() {
        gradient.colors = gradientColorSet[colorIndex]
        
        let gradientAnimation = CABasicAnimation(keyPath: "colors")
        gradientAnimation.delegate = self
        gradientAnimation.duration = 3.0
        
        self.updateColorIndex()
        gradientAnimation.toValue = gradientColorSet[colorIndex]
        
        gradientAnimation.fillMode = .forwards
        gradientAnimation.isRemovedOnCompletion = false
        
        gradient.add(gradientAnimation, forKey: "colors")
    }
    
    private func updateColorIndex() {
        if colorIndex < gradientColorSet.count - 1 {
            colorIndex += 1
        } else {
            colorIndex = 0
        }
    }
    
}

// MARK: -
extension BOMineVC: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.animateGradient()
        }
    }
    
}
