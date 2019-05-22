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
    let searchController = UISearchController(searchResultsController: nil)
    var notes: Results<Note>? {
        didSet {
            self.notesTable.reloadData()
        }
    }
    var searchResults : Results<Note>? {
        didSet {
            self.notesTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        notesTable.delegate = self
        notesTable.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Search"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        notes = RealmManager.shared.fetchNotes()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToNoteDetail", sender: sender)
    }
    
    
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        ActivityAlertPresenterManager.shared.presentActivityShieldForSorting(delegate: self)
    }
    
    //MARK: - Prepeare for segue function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! NoteDetailViewController
        if  sender.self is UIBarButtonItem {
            //case where we adding new note is shecking by asking type of sender
            let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: destVC, action: #selector(destVC.saveNewNoteButtonPressed))
            destVC.navigationItem.rightBarButtonItem = saveButton
        } else {
            //else we on editing/detail screen
            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: destVC, action: #selector(destVC.edit))
            let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: destVC, action: #selector(destVC.sharedButtonPressed))
            destVC.navigationItem.rightBarButtonItems = [editButton, shareButton]
            if let index = sender as? Int {
                //this part is working if we come from didSelectRowAtIndexPath
                  destVC.note = searchController.isActive ? searchResults?[index] : notes?[index]
            } else if let indexPath = sender as? IndexPath {
                //this part - if we come from tableViewRowAction and makes textView become firstResponder when segue peformed
                destVC.shoudEdit = true
                destVC.note = searchController.isActive ? searchResults?[indexPath.row] : notes?[indexPath.row]
            }
        } 
    }
    
    
}

//MARK: - TableViewMethods
extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //returns one or another nuber depending on searchController activity here and after using simular formula
        return (searchController.isActive ? searchResults?.count : notes?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! NoteCell
        let note = searchController.isActive ? searchResults?[indexPath.row] : notes?[indexPath.row]
        cell.date.text = note?.date.description(with: Locale.autoupdatingCurrent)
        cell.time.text = note?.date.description(with: Locale.autoupdatingCurrent)
        cell.noteText.text = note?.text.tuncateIfNeeded().withoutNewLine()
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
            [unowned self] action, index in
            guard let note = self.searchController.isActive ? self.searchResults?[index.row] : self.notes?[index.row] else {//present alert
                return}
            if !RealmManager.shared.delete(note: note) {
                //present alert
            }
            self.notes = RealmManager.shared.fetchNotes()
        }
        let edit = UITableViewRowAction(style: .normal, title: "Edit") {[unowned self] action, index in
            self.performSegue(withIdentifier: "goToNoteDetail", sender: index)
        }
        return [delete, edit]
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNoteDetail", sender: indexPath.row)
    }
}

//MARK: - Serch results updating
//Search result updating method
extension NotesViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            searchResults = notes?.filter("text CONTAINS[cd] %@", text)
        }
    }
}

//MARK: - Sorting
//All sorting goes here depending on choise made in ActivityVC and if it is need to sort searchResults or all notes
extension NotesViewController {
    func sortNotes(by property: String, ascending: Bool) {
        if searchController.isActive {
            searchResults = searchResults?.sorted(byKeyPath: property, ascending: ascending)
        } else {
            notes = notes?.sorted(byKeyPath: property, ascending: ascending)
        }
    }
}

//Making extension to string to return only 100 symbols truncated and replace all \n by spaces for more readable text in tableView
extension String {
    func tuncateIfNeeded() -> String {
        if self.count > 100 {
            let end = self.index(self.startIndex, offsetBy: 71)
            return "\(self[...end])..."
        } else {
            return self
        }
    }
    func withoutNewLine() -> String {
        return self.replacingOccurrences(of: "\n", with: " ")
    }
}

