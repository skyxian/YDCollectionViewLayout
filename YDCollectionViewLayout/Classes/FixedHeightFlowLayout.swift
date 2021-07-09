//
//  TagsFlowLayout.swift
//  YDPublicBusinessController
//
//  Created by 咸宝坤 on 2021/3/11.
//

import UIKit

@objc public protocol FixedHeightFlowLayoutDelegate {
    // itemSize
    func fixedHeightCollectionViewFlowLayout(_ layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    // 内边距
    @objc optional func fixedHeightCollectionViewFlowLayout(_ layout: UICollectionViewLayout, insetFor indexPath: IndexPath) -> UIEdgeInsets
    // 列间距
    @objc optional func fixedHeightCollectionViewFlowLayout(_ layout: UICollectionViewLayout, columnSpacingFor indexPath: IndexPath) -> CGFloat
    // 行间距
    @objc optional func fixedHeightCollectionViewFlowLayout(_ layout: UICollectionViewLayout, interSpacingFor indexPath: IndexPath) -> CGFloat
    // 将collectionView自适应布局后的高度返给外部
    @objc optional func fixedHeightCollectionViewFlowLayout(_ layout: UICollectionViewLayout, totalHeight: CGFloat)
}

// 固定高度，标签类布局

public class FixedHeightFlowLayout: UICollectionViewFlowLayout {

    public weak var delegate: FixedHeightFlowLayoutDelegate?
    
    public var attrsArray = [UICollectionViewLayoutAttributes]()
    
    // lastX 当前cell最右边X（originX+itemWidth）
    var lastX: CGFloat = 0
    // lastY 当前cell的originY
    var lastY: CGFloat = 0
    // 设置可滑动区域（contentSize）使用
    var totalHeight: CGFloat = 0
    // 设置最小高度
    public var minHeight: CGFloat = 0
        
    public init(sizeHeight: CGFloat? = 32, interitemSpacing: CGFloat? = 10) {
        super.init()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 作用：在这个方法中做一些初始化操作
    // 注意：一定要调用[super prepareLayout]
    public override func prepare() {
        super.prepare()
        print("版本升级测试")
        // 重新布局前清空数据
        self.lastX = 0
        self.lastY = 0
        self.totalHeight = 0
        self.attrsArray.removeAll()
        
        let sectionNumber: Int = collectionView?.numberOfSections ?? 0
        if sectionNumber == 0 {
            return
        }
        for section in 0 ..< sectionNumber {
            let itemCount: Int = collectionView!.numberOfItems(inSection: section)
            for item in 0 ..< itemCount {
                let itemIndexPath: IndexPath = IndexPath(item: item, section: section)
                let itemAttr = layoutAttributesForItem(at: itemIndexPath)
                if (itemAttr?.frame.size.height ?? 0) > 0 && (itemAttr?.frame.size.width ?? 0) > 0 {
                    attrsArray.append(itemAttr!)
                }
            }
        }
    }
    
    // 作用：
    // 这个方法的返回值是个数组
    // 这个数组中存放的都是UICollectionViewLayoutAttributes对象
    // UICollectionViewLayoutAttributes对象决定了cell的排布方式（frame等）
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }

    // 计算每一个UICollectionViewLayoutAttributes的frame
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        
        // 创建布局属性
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        // item size
        var itemSize = CGSize.zero
        if let delegate = self.delegate {
            itemSize = delegate.fixedHeightCollectionViewFlowLayout(self, sizeForItemAt: indexPath)
        }
        // 列间距
        var itemColumnSpacing: CGFloat = 10
        if let delegate = self.delegate {
            itemColumnSpacing = delegate.fixedHeightCollectionViewFlowLayout?(self, columnSpacingFor: indexPath) ?? 10
        }
        // 行间距
        var itemInterSpacing: CGFloat = 10
        if let delegate = self.delegate {
            itemInterSpacing = delegate.fixedHeightCollectionViewFlowLayout?(self, interSpacingFor: indexPath) ?? 10
        }
        // 缩进
        var sectionEdge = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if let delegate = self.delegate {
            sectionEdge = delegate.fixedHeightCollectionViewFlowLayout?(self, insetFor: indexPath) ?? UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        let itemCount: Int = collectionView.numberOfItems(inSection: indexPath.section)
        if itemCount == 0 {
            attr.frame = CGRect.zero
            return attr
        }

        // x坐标
        var attrX: CGFloat = 0
        // y坐标
        var attrY: CGFloat = 0
        var currentFrame = attr.frame
        currentFrame.size = itemSize

        // 预期 X
        attrX = indexPath.row == 0 ? sectionEdge.left : self.lastX + itemColumnSpacing
        
        // 宽度超出
        if attrX + itemSize.width > collectionView.frame.size.width {
            attrX = sectionEdge.left
            attrY = self.lastY + itemSize.height + itemInterSpacing
        } else {
            attrY = indexPath.row == 0 ? sectionEdge.top :  self.lastY
        }
        
        // lastX 当前cell最右边X
        self.lastX = attrX + itemSize.width
        // lastY 当前cell的originY
        self.lastY = attrY
        
        // 因为lastY是当前cell的originY，所以滑动区域需要+itemSize.height + sectionEdge.bottom
        if indexPath.item == itemCount - 1 {
            var minHeightTemp = collectionView.frame.size.height
            if minHeight != 0 {
                minHeightTemp = minHeight
            }
            totalHeight = max(self.lastY + itemSize.height + sectionEdge.bottom, minHeightTemp)
            self.delegate?.fixedHeightCollectionViewFlowLayout?(self, totalHeight: totalHeight + sectionEdge.top)
        }
        
        attr.frame = CGRect(x: attrX, y: attrY, width: itemSize.width, height: itemSize.height)
        return attr
    }
    
//    func evaluatedMinimumInteritemSpacing(at sectionIndex:Int) -> CGFloat {
//        if let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout, let collection = collectionView {
//            let inteitemSpacing = delegate.collectionView?(collection, layout: self, minimumInteritemSpacingForSectionAt: sectionIndex)
//            if let inteitemSpacing = inteitemSpacing {
//                return inteitemSpacing
//            }
//        }
//        return minimumInteritemSpacing
//    }
//    
//    func evaluatedSectionInsetForItem(at index: Int) ->UIEdgeInsets {
//        if let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout, let collection = collectionView {
//            let insetForSection = delegate.collectionView?(collection, layout: self, insetForSectionAt: index)
//            if let insetForSectionAt = insetForSection {
//                return insetForSectionAt
//            }
//        }
//        return sectionInset
//    }
    
    // 作用：如果返回YES，那么collectionView显示的范围发生改变时，就会重新刷新布局
    // 一旦重新刷新布局，就会按顺序调用下面的方法：
    // prepareLayout
    // layoutAttributesForElementsInRect:
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // 作用：返回值决定了collectionView停止滚动时最终的偏移量（contentOffset）
    // 参数：https://www.jianshu.com/p/3b1a47b94d4b
    // proposedContentOffset：原本情况下，collectionView停止滚动时最终的偏移量
    // velocity：滚动速率，通过这个参数可以了解滚动的方向
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//
//    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.frame.size.width ?? 0, height: totalHeight)
    }
}
