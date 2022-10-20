//
//  BKCardFlowLayout.swift
//  dysaidao
//
//  Created by Penlon Kim on 2021/4/1.
//  Copyright © 2021 王锦发. All rights reserved.
//

import UIKit

// 滚动切换回调方法
typealias BKCardScrollIndexChangeCallback = (Int) -> Void

// 布局类
class BKCardFlowLayout: UICollectionViewFlowLayout {
    
    enum Style {
        case zoom
        case center
    }
    
    var style: Style = .zoom
    var fixLeftInset: CGFloat = 0.0
    var miniLineSpace: CGFloat = 5.0
    // 卡片和父视图宽度比例
    var cardWidthScale: CGFloat = 0.7
    // 卡片和父视图高度比例
    var cardHeightScale: CGFloat = 0.8
    // 滚动到中间的回调方法
    var indexChangeCallback: BKCardScrollIndexChangeCallback?
    
    override func prepare() {
        self.scrollDirection = .horizontal // 水平滚动
        self.sectionInset = UIEdgeInsets(top: self.insetY(), left: self.insetX() + fixLeftInset, bottom: self.insetY(), right: self.insetX())
        self.itemSize = CGSize(width: self.itemWidth(), height: self.itemHeight())
        self.minimumLineSpacing = miniLineSpace
    }
    
    /**
     * 设置放大动画
     */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 获取cell的布局
        let originalAttributesArr = super.layoutAttributesForElements(in: rect)
        // 复制布局，以下操作，在复制布局中处理
        var attributesArr: Array<UICollectionViewLayoutAttributes> = Array()
        for attr: UICollectionViewLayoutAttributes in originalAttributesArr! {
            attributesArr.append(attr.copy() as! UICollectionViewLayoutAttributes)
        }
        
        // 屏幕中线
        let centerX: CGFloat = (self.collectionView?.contentOffset.x)! + (self.collectionView?.bounds.size.width)!/2.0
        
        // 最大移动距离，计算范围是移动出屏幕前的距离
        let maxApart: CGFloat = ((self.collectionView?.bounds.size.width)! + self.itemWidth())/2.0
        
        // 刷新cell缩放
        for attributes: UICollectionViewLayoutAttributes in attributesArr {
            // 获取cell中心和屏幕中心的距离
            let apart: CGFloat = abs(attributes.center.x - centerX)
            if style == .zoom {
                // 移动进度 -1~0~1
                let progress: CGFloat = apart/maxApart
                // 在屏幕外的cell不处理
                if abs(progress) > 1 { continue }
                // 根据余弦函数，弧度在 -π/4 到 π/4,即 scale在 √2/2~1~√2/2 间变化
                let scale: CGFloat = abs(cos(progress * CGFloat(Double.pi/4)))
                // 缩放大小
                var plane_3D: CATransform3D = .identity
                plane_3D = CATransform3DScale(plane_3D, 1, scale, 1)
                attributes.transform3D = plane_3D
            }
            // 更新中间位
            if apart <= self.itemWidth()/2.0 {
                self.indexChangeCallback?(attributes.indexPath.item)
            }
        }
        return attributesArr
    }
    
    // MARK: - 配置方法
    // 卡片宽度
    func itemWidth() -> CGFloat {
        return (self.collectionView?.bounds.size.width)! * cardWidthScale
    }
    
    // 卡片高度
    func itemHeight() -> CGFloat {
        return (self.collectionView?.bounds.size.height)! * cardHeightScale
    }
    
    // 设置左右缩进
    func insetX() -> CGFloat {
        let insetX: CGFloat = ((self.collectionView?.bounds.size.width)! - self.itemWidth())/2.0
        return insetX
    }
    
    // 上下缩进
    func insetY() -> CGFloat {
        let insetY: CGFloat = ((self.collectionView?.bounds.size.height)! - self.itemHeight())/2.0
        return insetY
    }
    
    // 是否实时刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}

// MARK: - BKCardViewDelegate
protocol BKCardViewDelegate: NSObjectProtocol {
    /// 滑动切换到新的位置
    func cardSwitchDidScrollToIndex(index: Int)
    /// 手动点击
    func cardSwitchDidSelectedAtIndex(index: Int)
    /// 将要开始拖拽
    func cardSwitchWillBeginDragging(_ scrollView: UIScrollView)
    /// 已经完成拖拽
    func cardSwitchDidEndDragging(_ scrollView: UIScrollView)
}

extension BKCardViewDelegate {
    func cardSwitchDidScrollToIndex(index: Int) { }
    func cardSwitchDidSelectedAtIndex(index: Int) { }
    func cardSwitchWillBeginDragging(_ scrollView: UIScrollView) { }
    func cardSwitchDidEndDragging(_ scrollView: UIScrollView) { }
}

// MARK: - BKCardViewDataSource
protocol BKCardViewDataSource: NSObjectProtocol {
    // 卡片个数
    func cardSwitchNumberOfCard() -> Int
    // 卡片cell
    func cardSwitchCellForItemAtIndex(index: Int) -> UICollectionViewCell
}

// 展示类
class BKCardView: UIView {
    
    deinit {
        self.removeTimer()
    }
    
    weak var delegate: BKCardViewDelegate?
    weak var dataSource: BKCardViewDataSource?
    var selectedIndex: Int = 0
    var pagingEnabled: Bool = false
    
    private var _dragStartX: CGFloat = 0
    private var _dragEndX: CGFloat = 0
    private var _dragAtIndex: Int = 0
    
    private let flowlayout = BKCardFlowLayout()
    
    // 是否无限滚动
    private var isInfinite: Bool = false
    // 是否自动滚动
    private var isAutoScroll: Bool = false
    // 滚动时间间隔
    private var scrollTimeInterval: TimeInterval = 3.0
    // 定时器
    private var timer: PKGCDTimer?
    
    lazy var _collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _collectionView.frame = self.bounds
    }
    
    private func loadUI() {
        self.addSubview(_collectionView)
        flowlayout.indexChangeCallback = { [weak self] index in
            guard let strongSelf = self else { return }
            strongSelf.addIndexChangeCallback(at: index)
        }
    }
    
}

// MARK: - UICollectionView代理
extension BKCardView: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let num = self.dataSource?.cardSwitchNumberOfCard(), num > 0 {
            if num == 1 {
                isInfinite = false
                isAutoScroll = false
                return num
            }
            if isInfinite {
                return num + 2 // 3 0 1 2 3 0 布局cell顺序
            } else {
                return num
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isInfinite {
            let num = self.dataSource?.cardSwitchNumberOfCard() ?? 0
            if indexPath.item == 0 {
                return (self.dataSource?.cardSwitchCellForItemAtIndex(index: num - 1))!
            } else if indexPath.item == num + 1 {
                return (self.dataSource?.cardSwitchCellForItemAtIndex(index: 0))!
            } else {
                return (self.dataSource?.cardSwitchCellForItemAtIndex(index: indexPath.item - 1))!
            }
        } else {
            return (self.dataSource?.cardSwitchCellForItemAtIndex(index: indexPath.item))!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        self.scrollToCenterAnimated(animated: true)
        if isInfinite {
            let num = self.dataSource?.cardSwitchNumberOfCard() ?? 0
            if indexPath.item == 0 {
                self.delegateSelectedAtIndex(index: num - 1)
            } else if indexPath.item == num + 1 {
                self.delegateSelectedAtIndex(index: 0)
            } else {
                self.delegateSelectedAtIndex(index: indexPath.item - 1)
            }
        } else {
            self.delegateSelectedAtIndex(index: indexPath.item)
        }
    }
    
}

// MARK: - UIScrollViewDelegate代理
extension BKCardView {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScroll {
            self.removeTimer()
        }
        self.delegateWillBeginDragging(scrollView)
        if !pagingEnabled { return }
        _dragStartX = scrollView.contentOffset.x
        _dragAtIndex = selectedIndex
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoScroll {
            self.addTimer()
        }
        self.delegateDidEndDragging(scrollView)
        if !pagingEnabled { return }
        _dragEndX = scrollView.contentOffset.x
        DispatchQueue.main.async {
            self.fixCellToCenter()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 3 0 1 2 3 0
        if isInfinite {
            let num = self.dataSource?.cardSwitchNumberOfCard() ?? 0
            if selectedIndex == 0 {
                self.autoScrollFixToPosition(index: num)
            } else if selectedIndex == num + 1 {
                self.autoScrollFixToPosition(index: 1)
            } else {
                
            }
        }
    }
    
}

// MARK: - Public
extension BKCardView {
    
    func reloadData() {
        _collectionView.reloadData()
        if isInfinite {
            self.autoScrollFixToPosition(index: 1)
        }
        if isAutoScroll {
            self.removeTimer()
            self.addTimer()
        }
        if let num = self.dataSource?.cardSwitchNumberOfCard(), num == 1 {
            self.removeAutoScroll()
        }
    }
    
    func reloadItem(item: Int) {
        _collectionView.reloadItems(at: [IndexPath(item: item, section: 0)])
    }
    
    func selectItem(item: Int) {
        _collectionView.selectItem(at: IndexPath(item: item, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }
    
    func setStyle(by style: BKCardFlowLayout.Style) {
        flowlayout.style = style
    }
    
    func setFixLeftInset(inset: CGFloat) {
        flowlayout.fixLeftInset = inset
    }
    
    func setFlowlayout(wScale: CGFloat = 0.7, hScale: CGFloat = 0.8) {
        flowlayout.cardWidthScale = wScale
        flowlayout.cardHeightScale = hScale
    }
    
    func setMiniLineSpace(_ miniLineSpace: CGFloat = 5.0) {
        flowlayout.miniLineSpace = miniLineSpace
    }
    
    func setScrollViewTag(_ tag: Int) {
        _collectionView.tag = tag
    }
    
    /// 设置是否自动滚动
    func isAutoScroll(_ autoScroll: Bool) {
        isAutoScroll = autoScroll
        if isAutoScroll {
            self.isInfinite(true)
        }
    }
    
    /// 设置是否无限滚动
    func isInfinite(_ infinite: Bool) {
        isInfinite = infinite
    }
    
    /// 移除自动滚动
    func removeAutoScroll() {
        isInfinite = false
        isAutoScroll = false
        self.removeTimer()
    }
    
    /// 设置滚动时间间隔
    func scrollTimeInterval(_ timeInterval: TimeInterval) {
        scrollTimeInterval = timeInterval
    }
    
    func switchToIndex(index: Int) {
        DispatchQueue.main.async {
            self.selectedIndex = index
            self.scrollToCenterAnimated(animated: true)
        }
    }
    
    func autoScrollFixToPosition(index: Int) {
        DispatchQueue.main.async {
            self.selectedIndex = index
            self.scrollToCenterAnimated(animated: false)
        }
    }
    
    // 向前切换
    func switchPrevious() {
        guard let index = self.currentIndex() else { return }
        var targetIndex = index - 1
        if !isInfinite {
            targetIndex = max(0, targetIndex)
        }
        self.switchToIndex(index: targetIndex)
    }
    
    // 向后切换
    func switchNext() {
        guard let index = self.currentIndex() else { return }
        var targetIndex = index + 1
        if !isInfinite {
            let maxIndex = (self.dataSource?.cardSwitchNumberOfCard())! - 1
            targetIndex = min(maxIndex, targetIndex)
        }
        self.switchToIndex(index: targetIndex)
    }
    
    func currentIndex() -> Int? {
        let x = _collectionView.contentOffset.x + _collectionView.bounds.width/2
        let index = _collectionView.indexPathForItem(at: CGPoint(x: x, y: _collectionView.bounds.height/2))?.item
        if isInfinite {
            let num = self.dataSource?.cardSwitchNumberOfCard() ?? 0
            if index == 0 {
                return num - 1
            } else if index == num + 1 {
                return 0
            } else {
                return (index ?? 1) - 1
            }
        } else {
            return index
        }
    }
    
    // MARK: - 数据源注册相关方法
    public func register<T: UICollectionViewCell>(cellWithClass name: T.Type) {
        _collectionView.register(T.self, forCellWithReuseIdentifier: String(describing: name))
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for index: Int) -> T {
        guard let cell = _collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: name), for: IndexPath(item: index, section: 0)) as? T else {
            fatalError("Couldn't find UICollectionViewCell for \(String(describing: name)), make sure the cell is registered with collection view")
        }
        return cell
    }
    
}

// MARK: - Private
extension BKCardView {
    
    private func addIndexChangeCallback(at index: Int) {
        if selectedIndex != index {
            selectedIndex = index
            // 3 0 1 2 3 0
            if isInfinite {
                let num = self.dataSource?.cardSwitchNumberOfCard() ?? 0
                if index == 0 {
                    self.delegateUpdateScrollIndex(index: num - 1)
                } else if index == num + 1 {
                    self.delegateUpdateScrollIndex(index: 0)
                } else {
                    self.delegateUpdateScrollIndex(index: index - 1)
                }
            } else {
                self.delegateUpdateScrollIndex(index: index)
            }
        }
    }
    
    // 回调滚动方法
    private func delegateUpdateScrollIndex(index: Int) {
        guard let _delegate = delegate else { return }
        _delegate.cardSwitchDidScrollToIndex(index: index)
    }
    
    // 回调点击方法
    private func delegateSelectedAtIndex(index: Int) {
        guard let _delegate = delegate else { return }
        _delegate.cardSwitchDidSelectedAtIndex(index: index)
    }
    
    // 回调将要开始拖拽方法
    private func delegateWillBeginDragging(_ scrollView: UIScrollView) {
        guard let _delegate = delegate else { return }
        _delegate.cardSwitchWillBeginDragging(scrollView)
    }
    
    // 回调已经完成拖拽方法
    private func delegateDidEndDragging(_ scrollView: UIScrollView) {
        guard let _delegate = delegate else { return }
        _delegate.cardSwitchDidEndDragging(scrollView)
    }
    
    private func addTimer() {
        timer = PKGCDTimer(interval: scrollTimeInterval, delaySecs: scrollTimeInterval, action: { [weak self] _ in
            self?.nextPage()
        })
        timer?.start()
    }
    
    private func removeTimer() {
        if timer != nil {
            timer?.cancel()
            timer = nil
        }
    }
    
    private func nextPage() {
        self.switchToIndex(index: selectedIndex + 1)
    }
    
    private func fixCellToCenter() {
        if selectedIndex != _dragAtIndex {
            self.scrollToCenterAnimated(animated: true)
            return
        }
        // 最小滚动距离
        let drawMinDistance: CGFloat = self.bounds.size.width/20.0
        if _dragStartX - _dragEndX >= drawMinDistance {
            selectedIndex -= 1 // 向右
        } else if _dragEndX - _dragStartX >= drawMinDistance {
            selectedIndex += 1 // 向左
        }
        
        let maxIndex: Int = _collectionView.numberOfItems(inSection: 0) - 1
        selectedIndex = max(selectedIndex, 0)
        selectedIndex = min(selectedIndex, maxIndex)
        self.scrollToCenterAnimated(animated: true)
    }
    
    // 滚动到中间
    private func scrollToCenterAnimated(animated: Bool) {
        guard let num = self.dataSource?.cardSwitchNumberOfCard(), num > 1, selectedIndex <= (num + 1) else { return }
        _collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
}
