//
//  ToolTipView.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-18.
//  Copyright © 2016 Sid. All rights reserved.
//

import UIKit

class ToolTipView: UIView {

    var title: String? = nil
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = StyleManager.themeColor
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .byWordWrapping
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.titleLabel.text = self.title
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
