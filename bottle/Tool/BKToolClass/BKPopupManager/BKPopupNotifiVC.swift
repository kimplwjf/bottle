//
//  BKPopupNotifiVC.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/11/23.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BKPopupNotifiVC: BKPopupManagerVC {
    
    deinit {
        tapHandler = nil
    }
    
    var text: String? {
        didSet { titleLabel.text = text }
    }
    
    var body: String? {
        didSet { bodyLabel.text = body }
    }
    
    var duration: TimeInterval = 5.0
    var tapHandler: ((String) -> Void)?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addSubview(bgView)
        bgView.addSubviews([iconImgView, titleLabel, bodyLabel])
        
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kStatusBarHeight)
            make.left.right.equalToSuperview().inset(12)
            make.width.equalTo(kScreenWidth-32)
        }
        
        iconImgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(38)
            make.left.equalToSuperview().offset(10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(10)
            make.top.equalToSuperview().offset(offset15)
            make.right.equalToSuperview().offset(-16)
        }
        
        bodyLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-offset15)
        }
        bgView.bk_addRandomCorners(radius: 15, corners: .allCorners)
        
        self.showAnimation()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 13.0, *) {
            bgView.bk_addBlur(style: .systemMaterial, alpha: 1.0)
        } else {
            bgView.bk_addBlur(style: BKDarkModeUtil.mode == .light ? .light : .dark, alpha: 1.0)
        }
    }
    
    @objc private func tapAction() {
        self.tapHandler?(configure.identifier)
    }
    
    @objc private func swipeAction() {
        let offset = kStatusBarHeight + bgView.bounds.size.height
        UIView.animate(withDuration: 0.35, delay: 0, options: .beginFromCurrentState) {
            self.bgView.transform = CGAffineTransform(translationX: 0, y: -offset)
        } completion: { _ in
            self.dismissAnimation { _ in
                BPM.dismiss(self.configure.identifier)
            }
        }
    }
    
    // MARK: - lazy
    lazy var bgView: UIView = {
        let view = UIView(color: .clear)
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipe.direction = .up
        view.addGestureRecognizer(swipe)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = self.bk_addLabel(font: .systemFont(ofSize: 16, weight: .semibold), bgColor: .clear, textColor: .lightBlackDarkWhite)
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
        let label = self.bk_addLabel(font: .systemFont(ofSize: 14), bgColor: .clear, textColor: .lightBlack51DarkLight230)
        return label
    }()
    
    private lazy var iconImgView: UIImageView = {
        let iv = UIImageView(image: LOGO.APPICON)
        return iv
    }()
    
}

// MARK: - Private
extension BKPopupNotifiVC {
    
    private func showAnimation() {
        UIView.animate(withDuration: 0.35, delay: 0, options: .beginFromCurrentState) {
            self.bgView.alpha = 1.0
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
                self.dismissAnimation { _ in
                    BPM.dismiss(self.configure.identifier)
                }
            }
        }
    }
    
    private func dismissAnimation(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.35, animations: {
            self.bgView.alpha = 0.0
        }, completion: completion)
    }
    
}
