//
//  CoreDataController.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    // Fetched Results Controller
    var allNotesFetchedResultController: NSFetchedResultsController<Note>?
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "LifeTravel")
        persistentContainer.loadPersistentStores() {(description,error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        super.init()
        
        // init notes
        if fetchAllNotes().count == 0 {
            initNotes()
        }
    }
    
    // MARK: - NSFetchedResultsController Delegate
    
    // Fetched Results Controller Protocol Functions
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listeners.invoke{(listener) in
            listener.onNoteListChange(change: .update, notes: fetchAllNotes())
        }
    }
    
    // Core Data Fetch Request
    func fetchAllNotes() -> [Note] {
        if allNotesFetchedResultController == nil {
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            
            // Sort by date
            let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [dateSortDescriptor]
            
            // fetch all notes
            allNotesFetchedResultController = NSFetchedResultsController<Note>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allNotesFetchedResultController?.delegate = self
            
            do {
                try allNotesFetchedResultController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        var notes = [Note]()
        if allNotesFetchedResultController?.fetchedObjects != nil {
            notes = (allNotesFetchedResultController?.fetchedObjects)!
        }
        
        return notes
    }
    
    // MARK: - Database Protocol
    func cleanup() {
        saveContext()
    }
    
    func addNote(date: String, location: String, lat: Double, long: Double, photo: String, content: String) -> Note {
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: persistentContainer.viewContext) as! Note
        note.date = date
        note.location = location
        note.lat = lat
        note.long = long
        note.photo = photo
        note.content = content
        
        return note
    }
    
    func addNote(date: String, location: String, lat: Double, long: Double, content: String) -> Note {
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: persistentContainer.viewContext) as! Note
        note.date = date
        note.location = location
        note.lat = lat
        note.long = long
        note.content = content
        
        return note
    }
    
    func deleteNote(note: Note) {
        persistentContainer.viewContext.delete(note)
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        listener.onNoteListChange(change: .update, notes: fetchAllNotes())
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // MARK: - Other Methods
    
    // init notes
    func initNotes() {
        print("init notes...")
        let _ = addNote(date: "2020-03-20", location: "37 Moonya Rd", lat: -37.896862, long: 145.059791, photo: "https://firebasestorage.googleapis.com/v0/b/fit5140-week09-labmessag-d81b2.appspot.com/o/PuMp0OF8K1fg7OwO61TtGH3RPUT2%2F1605617833?alt=media&token=9f142c8b-98fe-4d63-b2ee-a14703378322", content: "Here is the content on the 37 Moonya Road, and here is more information about this, lovely friend.")
        let _ = addNote(date: "2020-06-20", location: "67 Woornack Rd", lat: -37.898399, long: 145.062179, photo: "https://firebasestorage.googleapis.com/v0/b/fit5140-week09-labmessag-d81b2.appspot.com/o/PuMp0OF8K1fg7OwO61TtGH3RPUT2%2F1605617833?alt=media&token=9f142c8b-98fe-4d63-b2ee-a14703378322", content: "Here is the content on the 67 Woornack Road, and here is more information about this, home sweety home.")
        let _ = addNote(date: "2020-07-13", location: "24 Rosanna St", lat: -37.898691, long: 145.059814, photo: "https://firebasestorage.googleapis.com/v0/b/fit5140-week09-labmessag-d81b2.appspot.com/o/PuMp0OF8K1fg7OwO61TtGH3RPUT2%2F1605617833?alt=media&token=9f142c8b-98fe-4d63-b2ee-a14703378322", content: "Here is the content on the 24 Rosanna Street, and here is more information about this, nice garden.")
        let _ = addNote(date: "2020-09-22", location: "Koornang Park", lat: -37.894788, long: 145.054450, photo: "https://firebasestorage.googleapis.com/v0/b/fit5140-week09-labmessag-d81b2.appspot.com/o/PuMp0OF8K1fg7OwO61TtGH3RPUT2%2F1605617833?alt=media&token=9f142c8b-98fe-4d63-b2ee-a14703378322", content: "Here is the content on the Koornang Park, and here is more information about this, good park.")
        let _ = addNote(date: "2020-09-28", location: "Woolworths Carnegie", lat: -37.887559, long: 145.056396, photo: "https://firebasestorage.googleapis.com/v0/b/fit5140-week09-labmessag-d81b2.appspot.com/o/PuMp0OF8K1fg7OwO61TtGH3RPUT2%2F1605617833?alt=media&token=9f142c8b-98fe-4d63-b2ee-a14703378322", content: "Here is the content on the Woolworths Carnegie, and here is more information about this, nice shopping center.")
        let _ = addNote(date: "2020-10-11", location: "Bon Chicken & Beer", lat: -37.888330, long: 145.057039, photo: "https://firebasestorage.googleapis.com/v0/b/fit5140-week09-labmessag-d81b2.appspot.com/o/PuMp0OF8K1fg7OwO61TtGH3RPUT2%2F1605617833?alt=media&token=9f142c8b-98fe-4d63-b2ee-a14703378322", content: "Here is the content on the Bon Chicken & Beer, and here is more information about this, lovely place.")
        let _ = addNote(date: "2020-05-13", location: "State Library Victoria", lat: -37.809729, long: 144.965176, photo: "https://firebasestorage.googleapis.com/v0/b/fit5140-week09-labmessag-d81b2.appspot.com/o/PuMp0OF8K1fg7OwO61TtGH3RPUT2%2F1605617833?alt=media&token=9f142c8b-98fe-4d63-b2ee-a14703378322", content: "Here is the content on the State Library Victoria, and here is more information about this, huge miracle.")
    }
    
    // save change to CoreData
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save to CoreData: \(error)")
            }
        }
    }
    
}
