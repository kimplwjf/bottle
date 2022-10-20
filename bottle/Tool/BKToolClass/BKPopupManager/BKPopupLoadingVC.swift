//
//  BKPopupLoadingVC.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/11/17.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit
import Lottie

class BKPopupLoadingVC: BKPopupManagerVC {
    
    private let loadingType: LoadingType
    
    init(type: LoadingType = .default) {
        loadingType = type
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bgView)
        bgView.addSubview(loadingView)
        bgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(65)
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(55)
        }
        
    }
    
    // MARK: - lazy
    private lazy var bgView: UIView = {
        let view = UIView(color: .black.withAlphaComponent(0.3))
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var loadingView: AnimationView = {
        let view = AnimationView(name: loadingType.style.rawValue, bundle: BKUtils.bk_getCustomBundle(name: .Lottie))
        view.backgroundBehavior = .pauseAndRestore
        view.loopMode = .loop
        view.play()
        return view
    }()
    
}
