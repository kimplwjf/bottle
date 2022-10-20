//
//  BKPopupMomentumVC.swift
//  dysaidao
//
//  Created by Penlon Kim on 2022/4/18.
//  Copyright © 2022 王锦发. All rights reserved.
//

import UIKit

class BKPopupMomentumVC: BKPopupManagerVC {
    
    fileprivate var contentView: UIView!
    
    init(contentView: UIView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        view.addSubview(momentumView)
        momentumView.insertSubview(contentView, at: 0)
        
        momentumView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5)
            make.bottom.equalToSuperview()
            make.top.equalTo(kNavigationBarHeight+offset30)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tap)
        
        self.showAnimation()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            let momentumView = self.momentumView
            momentumView.closedTransform = momentumView.isOpen ? .identity : CGAffineTransform(translationX: 0, y: (momentumView.bounds.height)*0.6)
        }, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = momentumView.bounds
    }
    
    // MARK: - lazy
    private lazy var momentumView: BKMomentumView = {
        let view = BKMomentumView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .lightWhiteDark27
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
}

// MARK: - Selector
extension BKPopupMomentumVC {
    
    @objc private func tapAction() {
        self.dismissAnimation { _ in
            BPM.dismiss(self.configure.identifier)
        }
    }
    
}

// MARK: - Private
extension BKPopupMomentumVC {
    
    private func showAnimation() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let height = momentumView.bounds.height
        momentumView.closedTransform = CGAffineTransform(translationX: 0, y: height)
        UIView.animate(withDuration: 0.35) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            self.momentumView.closedTransform = CGAffineTransform(translationX: 0, y: height*0.6)
        }
    }
    
    private func dismissAnimation(completion: ((Bool) -> Void)? = nil) {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let height = momentumView.bounds.height
        UIView.animate(withDuration: 0.35, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.momentumView.closedTransform = CGAffineTransform(translationX: 0, y: height)
        }, completion: completion)
    }
    
}
