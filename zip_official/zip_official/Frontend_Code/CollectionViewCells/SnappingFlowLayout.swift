//
//  SnappingFlowLayout.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/6/21.
//

import UIKit

class SnappingFlowLayout: UICollectionViewFlowLayout {
    //Controls Snap to middle
    //https://newbedev.com/snap-to-center-of-a-cell-when-scrolling-uicollectionview-horizontally
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if scrollDirection == .vertical {
            guard let collectionView = collectionView else {
                let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
                return latestOffset
            }

            // Page height used for estimating and calculating paging.
            let pageHeight = itemSize.height + minimumLineSpacing

            // Make an estimation of the current page position.
            let approximatePage = collectionView.contentOffset.y/pageHeight

            // Determine the current page based on velocity.
            let currentPage = velocity.y == 0 ? round(approximatePage) : (velocity.y < 0.0 ? floor(approximatePage) : ceil(approximatePage))

            let newVerticalOffset = (currentPage * pageHeight) - collectionView.contentInset.top

            return CGPoint(x: proposedContentOffset.x,
                           y: newVerticalOffset)
        } else {
            guard let collectionView = collectionView else {
                let latestOffset = targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
                return latestOffset
            }

            // Page height used for estimating and calculating paging.
            let pageWdith = itemSize.width + minimumLineSpacing

            // Make an estimation of the current page position.
            let approximatePage = collectionView.contentOffset.x/pageWdith
            
            // Determine the current page based on velocity.
            let currentPage = velocity.x == 0 ? round(approximatePage) : (velocity.x < 0.0 ? floor(approximatePage) : ceil(approximatePage))

            let newHorizontalOffset = (currentPage * pageWdith) - collectionView.contentInset.left

            return CGPoint(x: newHorizontalOffset,
                           y: proposedContentOffset.y)
            
            
//            guard let collectionView = collectionView
//            else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
//
//            let parent = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
//
//            let itemSpace = itemSize.width + minimumInteritemSpacing
//            var currentItemIdx = round(collectionView.contentOffset.x / itemSpace)
//
//            // Skip to the next cell, if there is residual scrolling velocity left.
//            // This helps to prevent glitches
//            let vX = velocity.x
//            if vX > 0 {
//              currentItemIdx += 1
//            } else if vX < 0 {
//              currentItemIdx -= 1
//            }
//
//            let nearestPageOffset = currentItemIdx * itemSpace
//            return CGPoint(x: nearestPageOffset,
//                           y: parent.y)
        }
    
    }
    
//    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return true
//    }
}

