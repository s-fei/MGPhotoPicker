//
//  MGPhotoAnimator.swift
//  MogoRenter
//
//  Created by song on 16/8/13.
//  Copyright © 2016年 MogoRoom. All rights reserved.
//

/**
 跳转预览的专场动画
 */

import Foundation
import UIKit

class PresentAnimator: NSObject,UIViewControllerAnimatedTransitioning{
    let duration = 0.3
    var originView:UIView?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //1.获取动画的源控制器和目标控制器
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! MGPreViewImageController
        let container = transitionContext.containerView
        if originView == nil {
            originView = fromVC?.view
        }
        //2.创建一个 Cell 中 imageView 的截图，并把 imageView 隐藏，造成使用户以为移动的就是 imageView 的假象
        let snapshotView = originView!.snapshotView(afterScreenUpdates: false)
        snapshotView!.frame = container.convert(originView!.frame, from: originView!.superview)
        //        originView!.hidden = true
        
        //3.设置目标控制器的位置，并把透明度设为0，在后面的动画中慢慢显示出来变为1
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        //4.都添加到 container 中。注意顺序不能错了
        container.addSubview(toVC.view)
        container.addSubview(snapshotView!)
        //        container?.backgroundColor = UIColor.blackColor()
        
        //5.执行动画
        
        toVC.view.alpha = 1
        toVC.collectionView.isHidden = true
        toVC.bottomView.isHidden = true
        
        let finalHeight = KScreenWidth*snapshotView!.frame.height/snapshotView!.frame.width
        let finalFrame = CGRect(x: 0, y: (KScreenHeight - finalHeight)/2, width: KScreenWidth, height: finalHeight)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            snapshotView!.frame = finalFrame
        }) { (finish: Bool) -> Void in
            self.originView!.isHidden = false
            snapshotView!.removeFromSuperview()
            //            toVC.view.alpha = 1
            toVC.collectionView.isHidden = false
            toVC.bottomView.isHidden = false
            transitionContext.completeTransition(true)
            //            container?.backgroundColor = UIColor.clearColor()
            //            UIView.animateWithDuration(0.2, animations: {
            //                 toVC.view.alpha = 1
            //                }, completion: { (boo) in
            //                    self.originView!.hidden = false
            //                    snapshotView.removeFromSuperview()
            //                    fromVC?.view.alpha = 1
            //                    //一定要记得动画完成后执行此方法，让系统管理 navigation
            //                    transitionContext.completeTransition(true)
            //            })
        }
    }
}
class DismisssAnimator:NSObject,UIViewControllerAnimatedTransitioning{
    
    let duration = 0.3
    var fromView:UIView?
    var toView:UIView?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //1.获取动画的源控制器和目标控制器
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)as! MGPreViewImageController
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let container = transitionContext.containerView
        if toView == nil {
            toView = toVC.view
        }
        //2.创建一个 Cell 中 imageView 的截图，并把 imageView 隐藏，造成使用户以为移动的就是 imageView 的假象
        let snapshotView = toView!.snapshotView(afterScreenUpdates: false)
        snapshotView!.frame = container.convert(toView!.frame, from: toView!.superview)
        toView!.isHidden = true
        
        //3.设置目标控制器的位置，并把透明度设为0，在后面的动画中慢慢显示出来变为1
        fromVC!.view.frame = transitionContext.finalFrame(for: fromVC!)
        
        //4.都添加到 container 中。注意顺序不能错了
        container.addSubview(fromVC!.view)
        container.addSubview(snapshotView!)
        
        //5.执行动画
        
        fromVC!.view.alpha = 0
        toVC.view.alpha = 0
        
        let finalFrame = container.convert(fromView!.frame, from: fromView!.superview)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            snapshotView!.frame = finalFrame
            fromVC!.view.alpha = 1
        }) { (finish: Bool) -> Void in
            toVC.view.alpha = 1
            self.toView!.isHidden = false
            snapshotView!.removeFromSuperview()
            
            //一定要记得动画完成后执行此方法，让系统管理 navigation
            transitionContext.completeTransition(true)
        }
    }
}


