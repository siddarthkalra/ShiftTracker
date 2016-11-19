//
//  UIView+ToolTip.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-18.
//  Copyright © 2016 Sid. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    static let TAG_TOOL_TIP: Int = 1325
    
    func hideToolTip() {
        self.viewWithTag(UIView.TAG_TOOL_TIP)?.removeFromSuperview()
    }
    
    func showToolTip(_ title: String) {
        let toolTipView: ToolTipView = Bundle.main.loadNibNamed("ToolTipView", owner: self, options: nil)?.first as! ToolTipView
        toolTipView.tag = UIView.TAG_TOOL_TIP
        toolTipView.title = title
        
        // layout tool tip
        toolTipView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(toolTipView)
        
        let toolTipHeight:CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? self.bounds.size.height * 0.1 : self.bounds.size.height * 0.05
        self.addConstraint(NSLayoutConstraint(item: toolTipView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: toolTipView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: toolTipView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: toolTipHeight))
        
        let bottomConstraint = NSLayoutConstraint(item: toolTipView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: toolTipHeight)
        self.addConstraint(bottomConstraint)
        self.layoutIfNeeded()
        
        // Show the tool tip after a delay
        UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseOut, animations: {
            bottomConstraint.constant = 0.0
            self.layoutIfNeeded()
        }, completion: { (finished: Bool) -> Void in
            // Hide the tool tip after a delay
            UIView.animate(withDuration: 0.3, delay: 3.0, options: .curveEaseOut, animations: {
                bottomConstraint.constant = toolTipHeight
                self.layoutIfNeeded()
            }, completion: { (finished: Bool) -> Void in
                toolTipView.removeFromSuperview()
            })
        })
    }
}
