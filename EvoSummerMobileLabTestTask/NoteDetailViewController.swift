//
//  NoteDetailViewController.swift
//  EvoSummerMobileLabTestTask
//
//  Created by Denis Semerych on 5/16/19.
//  Copyright © 2019 Denis Semerych. All rights reserved.
//

import UIKit
import RealmSwift

class NoteDetailViewController: UIViewController {

    var note: Note?
    
    @IBOutlet weak var noteText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if note != nil {
            noteText.isEditable = false
            noteText.text = note!.text
        } else{
            noteText.isEditable = true
        }
    }
}



extension NoteDetailViewController {
    
   @objc func saveNote() {
        guard noteText.text != "" else {return}
        let note = Note()
        note.date = Date()
        note.text = noteText.text
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(note)
            }
        } catch {
            fatalError("Error in adding")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func edit() {
        noteText.isEditable = true
        let saveButton = UIBarButtonItem(title: "Ready", style: .plain, target: self, action: #selector(updateNote))
        self.navigationItem.rightBarButtonItem = saveButton
        noteText.becomeFirstResponder()
    }
    
    @objc func updateNote() {
        guard  noteText.text != "" else {return}
        let realm = try! Realm()
        do {
            try realm.write {
                self.note?.text = self.noteText.text
            }
        } catch {
            fatalError("Error in editing")
        }
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit))
        self.navigationItem.rightBarButtonItem = editButton
        noteText.resignFirstResponder()
        noteText.isEditable = false
    }
}
