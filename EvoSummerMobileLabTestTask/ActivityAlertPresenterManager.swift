//
//  ActivityAlertPresenterManager.swift
//  EvoSummerMobileLabTestTask
//
//  Created by Denis Semerych on 5/21/19.
//  Copyright © 2019 Denis Semerych. All rights reserved.
//

import UIKit

final class ActivityAlertPresenterManager {
    
    static var shared = ActivityAlertPresenterManager()
    
    @objc public func presentActivityVC(delegate: UIViewController, items: [String]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        delegate.present(activityVC, animated: true, completion: nil)
    }
    
    public func presentActivityShieldForSorting(delegate: NotesViewController) {
        let alertController = UIAlertController(title: "Sort", message: nil, preferredStyle: .actionSheet)
        let alphaAscending = UIAlertAction(title: "From A..Z", style: .default) { action in
            delegate.sortNotes(by: "text", ascending: true)
        }
        let dateAsending = UIAlertAction(title: "From new to old", style: .default) { action in
            delegate.sortNotes(by: "date", ascending: true)
        }
        let dateDescending = UIAlertAction(title: "From old to new", style: .default) { action in
            delegate.sortNotes(by: "date", ascending: false)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(alphaAscending)
        alertController.addAction(dateAsending)
        alertController.addAction(dateDescending)
        alertController.addAction(cancel)
        delegate.present(alertController, animated: true, completion: nil)
    }
    
    public func presentAlert(withMessage message: String, title: String, action: (()->Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
    }
    
    private init(){}
}
