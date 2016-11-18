//
//  FadeTransitionAnimator.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-18.
//  Copyright © 2016 Sid. All rights reserved.
//

import Foundation
import UIKit

class FadeTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC: UIViewController = transitionContext.viewController(forKey: .from)!
        let toVC: UIViewController = transitionContext.viewController(forKey: .to)!
        
        let containerView: UIView = transitionContext.containerView
        
        // When presenting: fromView = The presenting view | toView = The presented view
        // When dismissing: fromView = The presented view  | toView = The presenting view
        let fromView: UIView = transitionContext.view(forKey: .from)!
        let toView: UIView = transitionContext.view(forKey: .to)!
        
        fromView.frame = transitionContext.initialFrame(for: fromVC)
        toView.frame = transitionContext.finalFrame(for: toVC)

        fromView.alpha = 1.0
        toView.alpha = 0.0
        
        // We must explicitly add the incoming view to the containerView
        containerView.addSubview(toView)
        
        let transitionDuration: TimeInterval = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: transitionDuration, delay: 0, options: .curveEaseInOut, animations: {
            fromView.alpha = 0.0
            toView.alpha = 1.0
        }, completion: { (finished: Bool) -> Void in
            // Inform the transition context whether the transition was cancelled or not
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
