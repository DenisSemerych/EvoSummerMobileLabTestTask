//
//  ViewController.swift
//  EvoSummerMobileLabTestTask
//
//  Created by Denis Semerych on 5/15/19.
//  Copyright © 2019 Denis Semerych. All rights reserved.
//

import UIKit
import RealmSwift

class NotesViewController: UIViewController {

    @IBOutlet weak var notesTable: UITableView!
    var notes: Results<Note>? {
        didSet {
            self.notesTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTable.delegate = self
        notesTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchNotes()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToNoteDetail", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! NoteDetailViewController
        if  sender.self is UIBarButtonItem {
            let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: destVC, action: #selector(destVC.saveNote))
            destVC.navigationItem.rightBarButtonItem = saveButton
        } else if sender.self is Int {
            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: destVC, action: #selector(destVC.edit))
            destVC.navigationItem.rightBarButtonItem = editButton
            destVC.note = notes?[sender.self as! Int]
        }
    }
}


extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! NoteCell
        cell.date.text = notes?[indexPath.row].date.description(with: Locale.autoupdatingCurrent)
        cell.time.text = notes?[indexPath.row].date.description(with: Locale.autoupdatingCurrent)
        cell.noteText.text = notes?[indexPath.row].text.tuncateIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let title = NSAttributedString(string: "Delete", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24)])
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: deleteNote(_:_:))
        return [delete]
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNoteDetail", sender: indexPath.row)
    }
}


extension NotesViewController {
    func fetchNotes() {
            let realm = try! Realm()
            self.notes = realm.objects(Note.self)
    }
    
    func deleteNote(_ action: UITableViewRowAction, _ indexPath: IndexPath) {
        let realm = try! Realm()
        guard let note = notes?[indexPath.row] else {return}
        do {
            try realm.write {
                realm.delete(note)
            }
        } catch {
            fatalError("Error in deleting object")
        }
        fetchNotes()
    }
}

//Making extension to string to return only 100 symbols truncated
extension String {
    func tuncateIfNeeded() -> String {
        if self.count > 100 {
            let end = self.index(self.startIndex, offsetBy: 71)
            return "\(self[...end])..."
        } else {
            return self
        }
    }
}
