//
//  NoteDetailViewController.swift
//  EvoSummerMobileLabTestTask
//
//  Created by Denis Semerych on 5/16/19.
//  Copyright © 2019 Denis Semerych. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController{

    var note: Note?
    var shoudEdit = false
    
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        noteText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if note != nil {
            noteText.isEditable = false
            noteText.text = note!.text
        } else {
            noteText.isEditable = true
        }
        if shoudEdit {
            edit()
        } 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}



extension NoteDetailViewController {
    
    @objc func saveNewNoteButtonPressed() {
        guard noteText.text != "" else {//present alert
            return}
        if  !RealmManager.shared.saveNote(withText: noteText.text) {
            //present alert
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func edit() {
        noteText.isEditable = true
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonPressed))
        self.navigationItem.rightBarButtonItem = saveButton
        noteText.becomeFirstResponder()
    }
    
    @objc func saveButtonPressed() {
        guard  noteText.text != "" else {//present alert
            return}
        if !RealmManager.shared.updateNote(note: note!, withText: noteText.text) {
            //presentAlert
        }
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItem = editButton
        noteText.resignFirstResponder()
        noteText.isEditable = false
    }
}


extension NoteDetailViewController {
    
    @objc func sharedButtonPressed() {
        ActivityAlertPresenterManager.shared.presentActivityVC(delegate: self, items: [noteText.text!])
    }
    
}


extension NoteDetailViewController:  UITextViewDelegate {
    @objc func keyboardWillShow(notification: NSNotification) {
        adjustingHeight(keyboardHide: false, notification: notification)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
         adjustingHeight(keyboardHide: true, notification: notification)
    }
    
    func adjustingHeight(keyboardHide: Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let animationDurarion = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let changeInHeight = (keyboardFrame.height + 40) * (keyboardHide ? 1 : -1)
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.heightConstraint.constant += changeInHeight
        })
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        noteText.resignFirstResponder()
    }
}

