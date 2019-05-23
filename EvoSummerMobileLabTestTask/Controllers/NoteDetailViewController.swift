//
//  NoteDetailViewController.swift
//  EvoSummerMobileLabTestTask
//
//  Created by Denis Semerych on 5/16/19.
//  Copyright © 2019 Denis Semerych. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController {

    var note: Note?
    var shoudEdit = false
    private var saved = false
    
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //adding observers to notify on keyboard apears/disapears
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
        if shoudEdit {edit()}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //removing keyboard observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        //MARK: - coment next line if you need to disable saving data when poping self
        saveTextIfNeeded()
    }
}


//MARK: - Managing buttons action methods
extension NoteDetailViewController {
    
    @objc func saveNewNoteButtonPressed() {
        if !RealmManager.shared.saveNote(withText: noteText.text!) {
             ActivityAlertPresenterController.shared.presentAlert(delegate: self, withMessage: "Error in saving", title: "Realm Error")
        }
        saved = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func edit() {
        noteText.isEditable = true
        //change button to cancel edition
        let cancelEditionButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEditionButtonPressed))
        self.navigationItem.rightBarButtonItem = cancelEditionButton
        noteText.becomeFirstResponder()
    }
    
    @objc func saveButtonPressed() {
        if !RealmManager.shared.updateNote(note: note!, withText: noteText.text) {
               ActivityAlertPresenterController.shared.presentAlert(delegate: self, withMessage: "Error in updating note", title: "Realm Error")
        }
        saved = true
        turnOffEditonMode()
    }
    
    @objc func cancelEditionButtonPressed() {
        turnOffEditonMode()
    }
    
    func turnOffEditonMode() {
        changeBarButtonToEdit()
        noteText.resignFirstResponder()
        noteText.isEditable = false
    }
    
    func changeBarButtonToEdit() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    @objc func sharedButtonPressed() {
        ActivityAlertPresenterController.shared.presentActivityVC(delegate: self, items: [noteText.text!])
    }
    
    //MARK: - Saving Text on exit
    func saveTextIfNeeded() {
        if !saved && noteText.text != note?.text {
            if note != nil  {
               _ = RealmManager.shared.updateNote(note: note!, withText: noteText.text)
            } else {
                _ = RealmManager.shared.saveNote(withText: noteText.text)
            }
        }
    }
}

//MARK: - Methods of changing textView height in case keyboard is shown
extension NoteDetailViewController{
    @objc func keyboardWillShow(notification: NSNotification) {
        adjustingHeight(keyboardHide: false, notification: notification)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
         adjustingHeight(keyboardHide: true, notification: notification)
    }
    
    func adjustingHeight(keyboardHide: Bool, notification:NSNotification) {
        //taking info dict
        var userInfo = notification.userInfo!
        //taking frame size of keyboard
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        //taking animation time to peform nice
        let animationDurarion = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        //calculating change in height in case of showing or removing keyboard
        let changeInHeight = (keyboardFrame.height + 40) * (keyboardHide ? 1 : -1)
        UIView.animate(withDuration: animationDurarion, animations: {self.heightConstraint.constant += changeInHeight})
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        noteText.resignFirstResponder()
    }
}


//MARK: - TextViewDelegate methods
extension NoteDetailViewController:  UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //disabeling share button when edition starts
        switchShare(enabled: false)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //adding save button if note was edited
        if note != nil {
            let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonPressed))
            self.navigationItem.rightBarButtonItem = saveButton
        }
        //switching save button to prevent saving empty notes
        textView.text.isEmpty ? switchSave(enabled: false) : switchSave(enabled: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //enabeling share button when edition finished
        switchShare(enabled: true)
    }
}


//MARK: - Methods to disable/enable buttons
extension NoteDetailViewController {
    func switchSave(enabled: Bool) {
        let saveButton = navigationItem.rightBarButtonItems?.filter({$0.title == "Save"}).first
        saveButton?.isEnabled = enabled
    }
    
    func switchShare(enabled: Bool) {
        let shareButton = navigationItem.rightBarButtonItems?.filter({$0.title == "Share"}).first
        shareButton?.isEnabled = enabled
    }
}
