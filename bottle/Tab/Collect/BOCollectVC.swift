//
//  BOCollectVC.swift
//  bottle
//
//  Created by Penlon Kim on 2022/10/17.
//  Copyright © 2022 Kim. All rights reserved.
//

import UIKit
import Lottie

class BOCollectVC: BaseVC {
    
    override var backBarButtonItemHidden: Bool {
        return true
    }
    
    private var likeCollect: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviBarBackgroundAlpha = 0
        
        view.addSubview(bgImgView)
        bgImgView.addSubviews([kTitleLabel, listBtn, seaLottie, spotlightLottie, resultBgView, likeBtn])
        resultBgView.addSubview(resultLabel)
        bgImgView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(-kNavigationBarHeight)
        }
        
        kTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(32)
            make.height.equalTo(40)
            make.top.equalTo(kNavigationBarHeight)
        }
        
        listBtn.snp.makeConstraints { make in
            make.centerY.equalTo(kTitleLabel)
            make.right.equalTo(-16)
            make.size.equalTo(36)
        }
        
        seaLottie.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-30)
            make.size.equalTo(60)
        }
        
        spotlightLottie.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(kScreenWidth*0.6)
        }
        
        resultBgView.snp.makeConstraints { make in
            make.top.equalTo(kNavigationBarHeight*2)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(kScreenWidth-40)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        likeBtn.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.right.equalTo(resultBgView.snp.right).offset(-5)
            make.top.equalTo(resultBgView.snp.bottom).offset(12)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !bgImgView.subviews.contains(where: { $0 is UIVisualEffectView }) {
            bgImgView.bk_addBlur(style: .dark, alpha: 0.8)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        seaLottie.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        seaLottie.stop()
    }
    
    // MARK: - lazy
    private lazy var bgImgView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icon_collect_sea"))
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var kTitleLabel = self.bk_addLabel(text: "试着捞捞看～", font: .systemFont(ofSize: 30, weight: .medium), bgColor: .clear, textColor: XMColor.light230)
    
    private lazy var listBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon_list"), for: .normal)
        btn.bk_addTarget { [unowned self] sender in
            let vc = BOCollectListVC()
            self.navigationController?.pushViewController(vc)
        }
        return btn
    }()
    
    private lazy var spotlightLottie: AnimationView = {
        let gif = AnimationView(name: LottieType.gusto_spotlight.rawValue, bundle: BKUtils.bk_getCustomBundle(name: .Lottie))
        gif.contentMode = .scaleAspectFit
        gif.loopMode = .repeat(3.0)
        gif.isHidden = true
        return gif
    }()
    
    private lazy var seaLottie: AnimationView = {
        let gif = AnimationView(name: LottieType.gusto_sea.rawValue, bundle: BKUtils.bk_getCustomBundle(name: .Lottie))
        gif.contentMode = .scaleAspectFit
        gif.loopMode = .loop
        gif.whenTap { [unowned self] tap in
            self.throwAction()
        }
        return gif
    }()
    
    private lazy var resultBgView: UIView = {
        let view = UIView(color: .lightWhiteDark27)
        view.bk_addStyleWith(cornerRadius: 15, corners: .allCorners)
        view.isHidden = true
        return view
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = self.bk_addLabel(font: .systemFont(ofSize: 20, weight: .medium), bgColor: .clear, textColor: .lightBlack51DarkLight230)
        label.isHidden = true
        return label
    }()
    
    private lazy var likeBtn: BOAnimationButton = {
        let btn = BOAnimationButton(image: UIImage(named: "icon_like")!)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        return btn
    }()
    
}

// MARK: - Selector
extension BOCollectVC {
    
    @objc private func likeAction(sender: BOAnimationButton) {
        sender.isSelected ? sender.deselect() : sender.select()
        if sender.isSelected {
            let model = DBCollectModel()
            model.userId = XMApp.kUserId
            model.collect = likeCollect
            DB.shared.insert(object: model, intoTable: .collect)
        } else {
            DB.shared.delete(table: .collect, where: DBCollectModel.Properties.userId == XMApp.kUserId && DBCollectModel.Properties.collect == likeCollect)
        }
    }
    
}

// MARK: - Private
extension BOCollectVC {
    
    private func throwAction() {
        self.lookingfor(seek: true)
        spotlightLottie.play { [weak self] finish in
            if finish {
                self?.get_sweetNothings()
            }
        }
    }
    
    private func lookingfor(seek: Bool) {
        kTitleLabel.isHidden = seek
        seaLottie.isHidden = seek
        spotlightLottie.isHidden = !seek
        resultBgView.isHidden = seek
        resultLabel.isHidden = seek
        likeBtn.isHidden = seek
        listBtn.isHidden = seek
        if seek {
            likeBtn.isSelected = false
        }
    }
    
}

// MARK: - 网络请求
extension BOCollectVC {
    
    fileprivate func get_sweetNothings() {
        self.bk_showLoading()
        guard let req = try? URLRequest(url: "https://api.lovelive.tools/api/SweetNothings", method: .get) else { return }
        URLSession.shared.dataTask(with: req) { [weak self] data, resp, error in
            DispatchQueue.main.async {
                self?.bk_hideLoading()
                guard let data = data else {
                    BPM.showAlert(.warning, msg: XMNetBusy)
                    return
                }
                let text = String(data: data, encoding: .utf8)
                self?.likeCollect = text ?? ""
                self?.resultLabel.text = text
                self?.resultLabel.bk_alignTop()
                self?.lookingfor(seek: false)
            }
        }.resume()
    }
    
}
