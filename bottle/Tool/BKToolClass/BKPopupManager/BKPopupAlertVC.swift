//
//  BKPopupAlertVC.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/12/1.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit
import Lottie

class BKPopupAlertVC: BKPopupManagerVC {
    
    enum AlertType {
        case success
        case warning
        
        var style: LottieType {
            switch self {
            case .success: return .gusto_alert_success
            case .warning: return .gusto_alert_warning
            }
        }
    }
    
    enum PositionType: Int {
        case top = 0
        case center
        case bottom
    }
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    var duration: TimeInterval = 2.0
    private let alertType: AlertType
    private let positionType: PositionType
    
    init(type: AlertType, position: PositionType) {
        alertType = type
        positionType = position
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bgView)
        bgView.addSubviews([lottieView, textLabel])
        switch positionType {
        case .top:
            bgView.snp.makeConstraints { make in
                make.centerX.top.equalToSuperview()
                make.size.equalTo(CGSize(width: kScreenWidth/2, height: 36))
            }
        case .center:
            bgView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: kScreenWidth/2, height: 36))
            }
        case .bottom:
            bgView.snp.makeConstraints { make in
                make.centerX.bottom.equalToSuperview()
                make.size.equalTo(CGSize(width: kScreenWidth/2, height: 36))
            }
        }
        
        lottieView.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.left.equalToSuperview().offset(7)
            make.centerY.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints { make in
            make.left.equalTo(lottieView.snp.right).offset(7)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-7)
        }
        
        self.showAnimation()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let w: CGFloat = text?.widthWithFont(fixedHeight: 36) ?? 0
        let bgWidth: CGFloat = 30+7*3+w+12
        let _width: CGFloat = bgWidth > kScreenWidth-32 ? kScreenWidth-32 : bgWidth
        
        let h: CGFloat = text?.heightWithFont(fixedWidth: _width) ?? 36
        let bgHeight: CGFloat = h + 20
        let _height: CGFloat = bgHeight <= 36 ? 36 : bgHeight
        
        bgView.snp.updateConstraints { make in
            make.size.equalTo(CGSize(width: _width, height: _height))
        }
    }
    
    // MARK: - lazy
    private lazy var bgView: UIView = {
        let view = UIView(color: XMColor.black51)
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var lottieView: AnimationView = {
        let view = AnimationView(name: alertType.style.rawValue, bundle: BKUtils.bk_getCustomBundle(name: .Lottie))
        view.loopMode = .playOnce
        view.play()
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = self.bk_addLabel(font: .systemFont(ofSize: 15, weight: .medium), bgColor: .clear, textColor: .white)
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
}

// MARK: - Selector
extension BKPopupAlertVC {
    
    @objc private func tapAction() {
        self.dismissAnimation { _ in
            BPM.dismiss(self.configure.identifier)
        }
    }
    
}

// MARK: - Private
extension BKPopupAlertVC {
    
    private func showAnimation() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.showPopup()
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
            self.dismissPopup()
        }, completion: completion)
    }
    
    private func showPopup() {
        switch positionType {
        case .top:
            let offset = kStatusBarHeight + bgView.bounds.size.height
            bgView.transform = CGAffineTransform(translationX: 0, y: offset)
        case .center:
            bgView.alpha = 1.0
            bgView.bk_scaleAnimate()
        case .bottom:
            let offset = kTabBarHeight + bgView.bounds.size.height
            bgView.transform = CGAffineTransform(translationX: 0, y: -offset)
        }
    }
    
    private func dismissPopup() {
        switch positionType {
        case .top, .bottom:
            bgView.transform = .identity
        case .center:
            bgView.alpha = 0.0
        }
    }
    
}
