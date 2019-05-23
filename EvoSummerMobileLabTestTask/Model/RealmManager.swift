//
//  RealmManager.swift
//  EvoSummerMobileLabTestTask
//
//  Created by Denis Semerych on 5/19/19.
//  Copyright © 2019 Denis Semerych. All rights reserved.
//

import RealmSwift


final class RealmManager {
    
    static var shared = RealmManager()
    private let realm = try! Realm()
    
    public func updateNote(note: Note, withText text: String) -> Bool {
        guard text != "" else {return false}
        do {
            try realm.write {
                note.text = text
                note.date = Date()
            }
        } catch {
            return false
        }
        return true
    }
    
    public func saveNote(withText text: String) -> Note? {
        let note = Note()
        note.date = Date()
        note.text = text
        do {
            try realm.write {
                realm.add(note)
            }
        } catch {
            return nil
        }
        return note
    }
    
    public func delete(note: Note) -> Bool {
        do {
            try realm.write {
                realm.delete(note)
            }
        } catch {
            return false
        }
        return true
    }
    
    public func fetchNotes() -> Results<Note> {
        return realm.objects(Note.self)
    }
    
    private init() {}
}
