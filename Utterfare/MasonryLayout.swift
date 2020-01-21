//
//  MasonryLayout.swift
//  Utterfare
//
//  Created by Connor Meehan on 1/15/20.
//  Copyright © 2020 Utterfare. All rights reserved.
//

import Foundation
import UIKit

protocol MasonryLayoutDelegate: AnyObject{
    func collectionView(_ collectionView: UICollectionView, heightForObjectAtIndexPath indexPath: IndexPath) -> CGFloat
    func theNumberOfItemsInCollectionView() -> Int
}

class MasonryLayout: UICollectionViewLayout{
    weak var delegate: MasonryLayoutDelegate?
    
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var contentHeight: CGFloat = 0
    
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else{
            return 0
        }
        let insets = collectionView.contentInset
        
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare(){
        guard cache.isEmpty, let collectionView = collectionView else{ return }
                
        let columnWidth = contentWidth / CGFloat(numberOfColumns)

        var column = 0
        var count = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        var xOffset: [CGFloat] = []
        
        for column in 0..<numberOfColumns{
            xOffset.append(CGFloat(column) * columnWidth)
        }
        
        for item in 0..<(self.delegate?.theNumberOfItemsInCollectionView() ?? 0){ //collectionView.numberOfItems(inSection: 0){
            let indexPath = IndexPath(item: item, section: 0)
            
            let objectHeight = delegate?.collectionView(collectionView, heightForObjectAtIndexPath: indexPath) ?? 180

            let dimensions = cellPadding * 2 + objectHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: dimensions)
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            
            yOffset[column] = yOffset[column] + dimensions
            
            count += 1
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
        
        collectionView.allowsSelection = true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attributes in cache {
            if attributes.frame.intersects(rect){
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    
}
