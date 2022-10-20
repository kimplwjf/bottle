//
//  BOThrowVC.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/17.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit
import Lottie

class BOThrowVC: BaseVC {
    
    override var backBarButtonItemHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviBarBackgroundAlpha = 0
        
        view.addSubview(bgImgView)
        bgImgView.addSubviews([textView, lottieView])
        bgImgView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(-kNavigationBarHeight)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(kNavigationBarHeight)
            make.left.right.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        lottieView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.size.equalTo(60)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !bgImgView.subviews.contains(where: { $0 is UIVisualEffectView }) {
            bgImgView.bk_addBlur(style: .light, alpha: 0.9)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lottieView.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lottieView.stop()
    }
    
    // MARK: - lazy
    private lazy var bgImgView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icon_throw_sea"))
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var textView: BOThrowTextView = {
        let tv = BOThrowTextView()
        return tv
    }()
    
    private lazy var lottieView: AnimationView = {
        let gif = AnimationView(name: LottieType.gusto_throw.rawValue, bundle: BKUtils.bk_getCustomBundle(name: .Lottie))
        gif.contentMode = .scaleAspectFit
        gif.loopMode = .loop
        gif.whenTap { [unowned self] tap in
            self.throwAction()
        }
        return gif
    }()
    
}

// MARK: - Private
extension BOThrowVC {
    
    private func throwAction() {
        if textView.kTextView.text.isBlank() {
            BPM.showAlert(.warning, msg: "你还没说呢,别急~")
        } else {
            self.bk_showLoading()
            BKTaskUtil.delay(0.5) {
                self.bk_hideLoading()
                self.textView.kTextView.text = ""
                BPM.showResult(.success, msg: "成功扔向大海啦~")
            }
        }
    }
    
}
