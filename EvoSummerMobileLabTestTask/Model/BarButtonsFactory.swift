//
//  BarButtonsFactory.swift
//  
//
//  Created by Denis Semerych on 5/23/19.
//

import UIKit

enum ButtonType: String {
    case edit = "Edit", save = "Save", share, cancel = "Cancel"
}

class BarButtonsFactory {
    
    static func createButton(buttonType: ButtonType, with action: Selector, for vc: UIViewController) -> UIBarButtonItem {
        if buttonType == .share {
            return UIBarButtonItem(barButtonSystemItem: .action, target: vc, action: action)
        }
        return UIBarButtonItem(title: buttonType.rawValue, style: .plain, target: vc, action: action)
    }
    
    private init() {}
}
