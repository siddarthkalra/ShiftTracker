//
//  ToolTipView.swift
//  ShiftTracker
//
//  Created by Sid on 2016-11-18.
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
        self.titleLabel.font = self.titleLabel.font.bold()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.titleLabel.font = self.titleLabel.font.withSize(15.0)
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.titleLabel.text = self.title
    }
}
