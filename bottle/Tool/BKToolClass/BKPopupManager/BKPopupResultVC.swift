//
//  BKPopupResultVC.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/11/25.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit
import Lottie

class BKPopupResultVC: BKPopupManagerVC {
    
    enum ResultType {
        case success
        case error
        
        var style: LottieType {
            switch self {
            case .success: return .gusto_result_success
            case .error: return .gusto_result_error
            }
        }
    }
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    var duration: TimeInterval = 1.5
    private let resultType: ResultType
    
    init(type: ResultType) {
        resultType = type
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bgView)
        bgView.addSubviews([resultView, textLabel])
        bgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(kScreenWidth/3)
        }
        
        resultView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.size.equalTo(kScreenWidth/4)
        }
        
        textLabel.snp.makeConstraints { make in
            make.left.bottom.right.centerX.equalToSuperview()
            make.top.equalTo(resultView.snp.bottom)
        }
        
        self.showAnimation()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if text == nil {
            textLabel.removeFromSuperview()
            resultView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(kScreenWidth/4)
            }
        }
    }
    
    // MARK: - lazy
    private lazy var bgView: UIView = {
        let view = UIView(color: .black.withAlphaComponent(0.5))
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var resultView: AnimationView = {
        let view = AnimationView(name: resultType.style.rawValue, bundle: BKUtils.bk_getCustomBundle(name: .Lottie))
        view.loopMode = .playOnce
        view.play()
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = self.bk_addLabel(font: .systemFont(ofSize: 15, weight: .medium), bgColor: .clear, textColor: .white, align: .center)
        return label
    }()
    
}

// MARK: - Private
extension BKPopupResultVC {
    
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
