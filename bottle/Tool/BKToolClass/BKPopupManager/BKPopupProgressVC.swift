//
//  BKPopupProgressVC.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/12/8.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

class BKPopupProgressVC: BKPopupManagerVC {
    
    /// 提示文字
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    /// 限制progress次数
    var limitCount: Int = 1
    
    /// 当前进度
    var progress: Int = 0 {
        didSet {
            if limitCount > 1 {
                if progress < 100 {
                    progressView.setProgress(progress, animated: true)
                } else {
                    limitCount -= 1
                    progress = 0
                }
            } else {
                if progress < 100 {
                    progressView.setProgress(progress, animated: true)
                } else {
                    self.dismissAnimation { _ in
                        BPM.dismiss(self.configure.identifier)
                    }
                }
            }
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bgView)
        bgView.addSubviews([progressView, textLabel])
        bgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(kScreenWidth/4)
        }
        
        progressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(6)
            make.size.equalTo(kScreenWidth/8)
        }
        
        textLabel.snp.makeConstraints { make in
            make.left.bottom.right.centerX.equalToSuperview()
            make.top.equalTo(progressView.snp.bottom)
        }
        
        self.showAnimation()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if text == nil {
            textLabel.removeFromSuperview()
            progressView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(kScreenWidth/8)
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
    
    private lazy var progressView: BKCircleGradientProgressView = {
        let view = BKCircleGradientProgressView()
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = self.bk_addLabel(font: .systemFont(ofSize: 14, weight: .medium), bgColor: .clear, textColor: .white, align: .center)
        return label
    }()
    
}

// MARK: - Private
extension BKPopupProgressVC {
    
    private func showAnimation() {
        UIView.animate(withDuration: 0.35, delay: 0, options: .beginFromCurrentState) {
            self.bgView.alpha = 1.0
        }
    }
    
    private func dismissAnimation(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.35, animations: {
            self.bgView.alpha = 0.0
        }, completion: completion)
    }
    
}
