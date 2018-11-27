//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol AnyFilterViewController: AnyObject, BottomSheetPresentationControllerDelegate {
    var mainScrollableContentView: UIScrollView? { get }
    var isMainScrollableViewScrolledToTop: Bool { get }
}

public extension BottomSheetPresentationControllerDelegate where Self: AnyFilterViewController {
    func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomSheetPresentationController, willTransitionFromContentSizeMode current: BottomSheetPresentationController.ContentSizeMode, to new: BottomSheetPresentationController.ContentSizeMode) {
    }

    func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomSheetPresentationController, didTransitionFromContentSizeMode current: BottomSheetPresentationController.ContentSizeMode, to new: BottomSheetPresentationController.ContentSizeMode) {
        guard let scrollView = mainScrollableContentView else {
            return
        }
        switch (current, new) {
        case (_, .compact):
            scrollView.isScrollEnabled = false
        case (_, .expanded):
            scrollView.isScrollEnabled = true
        }
    }

    func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomSheetPresentationController, shouldBeginTransitionWithTranslation translation: CGPoint, from contentSizeMode: BottomSheetPresentationController.ContentSizeMode) -> Bool {
        guard let scrollView = mainScrollableContentView else {
            return true
        }
        switch contentSizeMode {
        case .expanded:
            let isDownwardTranslation = translation.y > 0.0

            if isDownwardTranslation {
                scrollView.isScrollEnabled = !isMainScrollableViewScrolledToTop
                return isMainScrollableViewScrolledToTop
            } else {
                return false
            }
        case .compact:
            let isUpwardTranslation = translation.y < 0.0

            if isUpwardTranslation {
                scrollView.isScrollEnabled = false
                return isMainScrollableViewScrolledToTop
            } else {
                return false
            }
        }
    }

    func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomSheetPresentationController, panningBeyondExpandedState additionalVerticalPan: CGFloat) {
        guard let scrollView = mainScrollableContentView else {
            return
        }
        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: additionalVerticalPan)
    }
}
