//
//  CloudViewController.swift
//  LifeTravel
//
//  Created by 苏桐 on 18/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CloudViewController: UIViewController, DatabaseListener {
    @IBOutlet weak var localNote: UILabel!
    @IBOutlet weak var localPhoto: UILabel!
    @IBOutlet weak var localLocation: UILabel!
    @IBOutlet weak var cloudNote: UILabel!
    @IBOutlet weak var cloudPhoto: UILabel!
    @IBOutlet weak var cloudLocation: UILabel!
    
    var userReference = Firestore.firestore().collection("users")
    var storageReference = Storage.storage().reference()
    var notesRef : CollectionReference?
    var firebaseListener: ListenerRegistration?
    
    var localNotes: [Note] = []
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set cloud note information
        getInfoNumber()
        // database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @IBAction func uploadNotes(_ sender: Any) {
        var localNotes = [Note]()
        //get all local notes
        localNotes = databaseController?.fetchAllNotes() as! [Note]
        //set up user
        guard let userID = Auth.auth().currentUser?.uid else {
            displayMessage("Cannot upload unitl logged in", "Error")
            return
        }
        // set note reference
        notesRef = self.userReference.document("\(userID)").collection("notes")
        
        notesRef!.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                //delete all notes on the cloud
                for doc in querySnapshot!.documents{
                    //clean up cloud notes
                    let docId = doc.documentID
                    self.notesRef!.document(docId).delete()
                }
                //upload all notes to the cloud
                for note in localNotes {
                    self.notesRef?.addDocument(data: [
                        "content": note.content!,
                        "date": note.date!,
                        "location": note.location!,
                        "photo": note.photo!,
                        "lat": note.lat,
                        "long": note.long
                    ])
                }
                
                // set cloud note information
                self.getInfoNumber()
            }
        }
        
        // Display message
        let alertController = UIAlertController(title: "Success",
               message: "Your notes have been uploaded!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func downloadNotes(_ sender: Any) {
        //delete all local notes
        databaseController?.deleteAll()
        //set up user
        guard let userID = Auth.auth().currentUser?.uid else {
            displayMessage("Cannot download unitl logged in", "Error")
            return
        }
        // set note reference
        notesRef = self.userReference.document("\(userID)").collection("notes")
        notesRef!.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                //get all notes on the cloud
                for doc in querySnapshot!.documents {
                    let content = doc["content"] as! String
                    let date = doc["date"] as! String
                    let location = doc["location"] as! String
                    let photo = doc["photo"] as! String
                    let lat = doc["lat"] as! Double
                    let long = doc["long"] as! Double
                    self.databaseController?.addNote(date: date, location: location, lat: lat, long: long, photo: photo, content: content)
                }
            }
        }
        
        //display success message
        let alertController = UIAlertController(title: "Success",
               message: "Your notes have been downloaded!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    // MARK: - Database Listener Functions
    func onNoteListChange(change: DatabaseChange, notes: [Note]) {
        self.localNotes = notes
        
        
        // set local note information
        localNote.text = String(localNotes.count)
        localPhoto.text = String(getPhotoNumber(allNotes: localNotes))
        localLocation.text = String(getLocationNumber(allNotes: localNotes))
        
        
    }
    
    // MARK: - Get Local Notes Informations
    func getLocationNumber(allNotes: [Note]) -> Int {
        var locations: [String] = []
        for note in allNotes {
            if note.location != "No Address" {
                locations.append(note.location!)
            }
        }
        
        // remove duplicate string
        let removeDup = locations.enumerated().filter {(index,value) -> Bool in
            return locations.firstIndex(of: value) == index }.map {$0.element}
        
        return removeDup.count
    }
    
    func getPhotoNumber(allNotes: [Note]) -> Int {
        var photos: [String] = []
        for note in allNotes {
            if note.photo != "" {
                photos.append(note.photo!)
            }
        }
        
        return photos.count
    }
    
    // MARK: - Get Cloud Note Informations
    func getInfoNumber() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            displayMessage("Cannot download unitl logged in", "Error")
            return
        }
        // set note reference
        notesRef = self.userReference.document("\(userID)").collection("notes")
        notesRef!.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                //get all notes on the cloud
                var noteNum: Int = 0
                var locationNum: Int = 0
                var photoNum: Int = 0
                for doc in querySnapshot!.documents {
                    noteNum += 1

                    let location = doc["location"] as! String
                    let photo = doc["photo"] as! String
                    
                    if location != "No Address" && location != "" {
                        locationNum += 1                    }
                    
                    if photo != "" {
                        photoNum += 1
                    }
                }
                // set cloud information
                self.cloudNote.text = String(noteNum)
                self.cloudPhoto.text = String(photoNum)
                self.cloudLocation.text = String(locationNum)
            }
        }
        
        return
    }
    
    // get current date
    func currentDate() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        let time = dateformatter.string(from: Date())
        return time
    }
    

    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
