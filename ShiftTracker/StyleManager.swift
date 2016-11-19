//
//  StyleManager.swift
//  ShiftTracker
//
//  Created by Sid on 2016-11-18.
//  Copyright © 2016 Sid. All rights reserved.
//

import Foundation
import UIKit

class StyleManager {
    
    static let themeColor = UIColor(colorLiteralRed: 0.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
    
    class func styleApp() {
        let navigationBarAppearnce = UINavigationBar.appearance()
        navigationBarAppearnce.tintColor = StyleManager.themeColor
        navigationBarAppearnce.titleTextAttributes = [NSForegroundColorAttributeName: StyleManager.themeColor]
        
        let colorView = UIView()
        colorView.backgroundColor = StyleManager.themeColor
        UITableViewCell.appearance().selectedBackgroundView = colorView
    }
}
