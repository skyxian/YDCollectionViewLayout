//
//  YDHorizontalScrollingLayout.swift
//  Idui
//
//  Created by 咸宝坤 on 2019/10/22.
//  Copyright © 2019 saxer. All rights reserved.
//

import UIKit

@objc protocol YDHorizontalScrollingLayoutDelegate {
    // itemSize
    func YDHorizontalCollectionViewFlowLayout(_ layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize

    // 内边距
    @objc optional func YDHorizontalCollectionViewFlowLayout(_ layout: UICollectionViewLayout, insetFor indexPath: IndexPath) -> UIEdgeInsets

    // 列间距
    @objc optional func YDHorizontalCollectionViewFlowLayout(_ layout: UICollectionViewLayout, columnSpacingFor indexPath: IndexPath) -> CGFloat
}

class YDHorizontalScrollingLayout: UICollectionViewFlowLayout {
    fileprivate var attrsArray = [UICollectionViewLayoutAttributes]()
    var contentWidth: CGFloat = 0
    var currentX: CGFloat = 0
    var sizeHeight: CGFloat = 0
    weak var delegate: YDHorizontalScrollingLayoutDelegate?

    init(sizeHeight: CGFloat? = 32) {
        super.init()
        self.sizeHeight = sizeHeight ?? 32
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        contentWidth = 0
        currentX = 0
        attrsArray.removeAll()

        let sectionNumber: Int = collectionView?.numberOfSections ?? 0
        if sectionNumber == 0 {
            return
        }
        for section in 0 ..< sectionNumber {
            // item
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

    // cell排布
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let collectionViewW = collectionView!.frame.size.width

        // item size
        var itemSize = CGSize.zero
        if let delegate = self.delegate {
            itemSize = delegate.YDHorizontalCollectionViewFlowLayout(self, sizeForItemAt: indexPath)
        }

        // 列间距
        var itemColumnSpacing: CGFloat = 10
        if let delegate = self.delegate {
            itemColumnSpacing = delegate.YDHorizontalCollectionViewFlowLayout?(self, columnSpacingFor: indexPath) ?? 10
        }

        var sectionEdge = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if let delegate = self.delegate {
            sectionEdge = delegate.YDHorizontalCollectionViewFlowLayout?(self, insetFor: indexPath) ?? UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }

        let itemCount: Int = collectionView!.numberOfItems(inSection: indexPath.section)
        if itemCount == 0 {
            attr.frame = CGRect.zero
            return attr
        }

        var currentFrame = attr.frame
        currentFrame.size = itemSize

        currentFrame.origin.y = sectionEdge.top
        if indexPath.item == 0 { // 第一个
            contentWidth = sectionEdge.left
            currentFrame.origin.x = contentWidth
        } else {
            currentFrame.origin.x = currentX + itemColumnSpacing
        }
        attr.frame = currentFrame
        currentX = attr.frame.maxX
        if indexPath.item == itemCount - 1 {
            contentWidth = max(attr.frame.maxX + sectionEdge.right, collectionViewW)
        }
        return attr
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: sizeHeight)
    }
}
