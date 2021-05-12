//
//  CustomAnimatedTranstioning.swift
//  YCPhotoBrowser
//
//  Created by Loveying on 05/11/2021.
//  Copyright (c) 2021 Loveying. All rights reserved.
//

import UIKit
import YCPhotoBrowser

/// 自定义转场动画
class CustomAnimatedTranstioning: NSObject, YCPhotoAnimatedTransitioning {
    
    var showDuration: TimeInterval = 0.25
    
    var dismissDuration: TimeInterval = 0.25
    
    var isNavigationAnimation = false
    
    typealias PreviousViewAtIndexClosure = (_ index: Int) -> UIView?
    
    /// 转场动画的前向视图
    var previousViewProvider: PreviousViewAtIndexClosure = { _ in nil }
    
    /// 替补的动画方案
    lazy var substituteAnimator: YCPhotoAnimatedTransitioning = YCPhotoFadeAnimator()
    
    public init(previousView: @escaping PreviousViewAtIndexClosure) {
        previousViewProvider = previousView
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isForShow ? showDuration : dismissDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isForShow {
            playShowAnimation(context: transitionContext)
        } else {
            playDismissAnimation(context: transitionContext)
        }
    }
    
    private func playShowAnimation(context: UIViewControllerContextTransitioning) {
        guard let browser = browser else {
            context.completeTransition(!context.transitionWasCancelled)
            return
        }
        if isNavigationAnimation,
            let fromView = context.view(forKey: .from),
            let fromViewSnapshot = snapshot(with: fromView),
            let toView = context.view(forKey: .to)  {
            toView.insertSubview(fromViewSnapshot, at: 0)
        }
        context.containerView.addSubview(browser.view)
        
        guard let (snap1, snap2, thumbnailFrame, destinationFrame) = snapshotsAndFrames(browser: browser) else {
            // 转为执行替补动画
            substituteAnimator.isForShow = isForShow
            substituteAnimator.browser = browser
            substituteAnimator.isNavigationAnimation = isNavigationAnimation
            substituteAnimator.animateTransition(using: context)
            return
        }
        snap1.frame = thumbnailFrame
        snap2.frame = thumbnailFrame
        snap2.alpha = 0
        browser.maskView.alpha = 0
        browser.browserView.isHidden = true
        context.containerView.addSubview(snap1)
        context.containerView.addSubview(snap2)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: UIView.AnimationOptions(),
            animations: {
                browser.maskView.alpha = 1.0
                snap1.frame = destinationFrame
                snap1.alpha = 0
                snap2.frame = destinationFrame
                snap2.alpha = 1.0
            },
            completion: { (_) -> Void in
               browser.browserView.isHidden = false
               browser.view.insertSubview(browser.maskView, belowSubview: browser.browserView)
               snap1.removeFromSuperview()
               snap2.removeFromSuperview()
               context.completeTransition(!context.transitionWasCancelled)
         })
    }
    
    private func playDismissAnimation(context: UIViewControllerContextTransitioning) {
        guard let browser = browser else {
            return
        }
        guard let (snap1, snap2, thumbnailFrame, destinationFrame) = snapshotsAndFrames(browser: browser) else {
            // 转为执行替补动画
            substituteAnimator.isForShow = isForShow
            substituteAnimator.browser = browser
            substituteAnimator.isNavigationAnimation = isNavigationAnimation
            substituteAnimator.animateTransition(using: context)
            return
        }
        snap1.frame = destinationFrame
        snap1.alpha = 0
        snap2.frame = destinationFrame
        context.containerView.addSubview(snap1)
        context.containerView.addSubview(snap2)
        browser.browserView.isHidden = true
        
        UIView.animate(
           withDuration: 0.5,
           delay: 0,
           usingSpringWithDamping: 0.8,
           initialSpringVelocity: 0,
           options: UIView.AnimationOptions(),
           animations: {
               browser.maskView.alpha = 0
               snap1.frame = thumbnailFrame
               snap1.alpha = 0
               snap2.frame = thumbnailFrame
               snap2.alpha = 1.0
           },
           completion: { (_) -> Void in
              if let toView = context.view(forKey: .to) {
                  context.containerView.addSubview(toView)
              }
              snap1.removeFromSuperview()
              snap2.removeFromSuperview()
              context.completeTransition(!context.transitionWasCancelled)
        })
    }
    
    private func snapshotsAndFrames(browser: YCPhotoBrowser) -> (UIView, UIView, CGRect, CGRect)? {
        let browserView = browser.browserView
        let view = browser.view
        let closure = previousViewProvider
        guard let previousView = closure(browserView.pageIndex) else {
            return nil
        }
        guard let cell = browserView.visibleCells[browserView.pageIndex] as? YCPhotoZoomCell else {
            return nil
        }
        let thumbnailFrame = previousView.convert(previousView.bounds, to: view)
        let showContentView = cell.showContentView
        // 两Rect求交集，得出显示中的区域
        let destinationFrame = cell.convert(cell.bounds.intersection(showContentView.frame), to: view)
        guard let snap1 = fastSnapshot(with: previousView) else {
            YCPhotoBrowserLog.high("取不到前截图！")
            return nil
        }
        guard let snap2 = snapshot(with: cell.showContentView) else {
            YCPhotoBrowserLog.high("取不到后截图！")
            return nil
        }
        return (snap1, snap2, thumbnailFrame, destinationFrame)
    }
    
    
}
