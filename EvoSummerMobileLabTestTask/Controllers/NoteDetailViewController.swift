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
    private var isTextSaved = false
    
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
           noteText.text = note?.text
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setupDisplayMode()
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
        if let note = RealmManager.shared.saveNote(withText: noteText.text!) {
            self.note = note
            isTextSaved = true
            let editButton = BarButtonsFactory.createButton(buttonType: .edit, with: #selector(edit), for: self)
            let shareButton = BarButtonsFactory.createButton(buttonType: .share, with: #selector(sharedButtonPressed), for: self)
            navigationItem.rightBarButtonItems = [editButton, shareButton]
            noteText.isEditable = false
        } else {
            ActivityAlertPresenterController.shared.presentAlert(delegate: self, withMessage: "Error in saving", title: "Realm Error")
        }
    }
    
    @objc func edit() {
        noteText.isEditable = true
        //change button to cancel edition
        let cancelEditionButton = BarButtonsFactory.createButton(buttonType: .cancel, with: #selector(cancelEditionButtonPressed), for: self)
        navigationItem.rightBarButtonItem = cancelEditionButton
        isTextSaved = false
        noteText.becomeFirstResponder()
    }
    
    @objc func saveButtonPressed() {
        if !RealmManager.shared.updateNote(note: note!, withText: noteText.text) {
               ActivityAlertPresenterController.shared.presentAlert(delegate: self, withMessage: "Error in updating note", title: "Realm Error")
        }
        isTextSaved = true
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
        let editButton = BarButtonsFactory.createButton(buttonType: .edit, with: #selector(edit), for: self)
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc func sharedButtonPressed() {
        if noteText.isFirstResponder {noteText.resignFirstResponder()}
        ActivityAlertPresenterController.shared.presentActivityVC(delegate: self, items: [noteText.text!])
    }
}

//MARK: - Saving Text on exit && changing input mode setup
extension NoteDetailViewController {
    func saveTextIfNeeded() {
        if !isTextSaved && noteText.text != note?.text && !noteText.text.isEmpty {
            if note != nil  {
                _ = RealmManager.shared.updateNote(note: note!, withText: noteText.text)
            } else {
                _ = RealmManager.shared.saveNote(withText: noteText.text)
            }
        }
    }
    
    func setupDisplayMode() {
        if note != nil && !shoudEdit {
            noteText.isEditable = false
        } else if shoudEdit {
            edit()
        } else {
            noteText.isEditable = true
            noteText.becomeFirstResponder()
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
    
    func textViewDidChange(_ textView: UITextView) {
        //adding save button if note was edited
        if note != nil {
            let saveButton = BarButtonsFactory.createButton(buttonType: .save, with: #selector(saveButtonPressed), for: self)
            self.navigationItem.rightBarButtonItem = saveButton
        }
        //switching save button to prevent saving empty notes
        textView.text.isEmpty ? switchSave(enabled: false) : switchSave(enabled: true)
    }
}


//MARK: - Methods to disable/enable saveButton
extension NoteDetailViewController {
    func switchSave(enabled: Bool) {
        let saveButton = navigationItem.rightBarButtonItems?.filter({$0.title == "Save"}).first
        saveButton?.isEnabled = enabled
    }
}
