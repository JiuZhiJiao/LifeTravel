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
    
    var userReference = Firestore.firestore().collection("users")
    var storageReference = Storage.storage().reference()
    var notesRef : CollectionReference?
    var firebaseListener: ListenerRegistration?
    
    var localNotes: [Note] = []
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let firebase = Firestore.firestore()
        
        
        // database
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
        localNotes = databaseController?.fetchAllNotes() as! [Note]
    
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
            }
        }
        
        let alertController = UIAlertController(title: "Success",
               message: "Your notes have been uploaded!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func downloadNotes(_ sender: Any) {
        databaseController?.deleteAll()
        
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
        
        let alertController = UIAlertController(title: "Success",
               message: "Your notes have been downloaded!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    // MARK: - Database Listener Functions
    func onNoteListChange(change: DatabaseChange, notes: [Note]) {
        self.localNotes = notes
        print("Local notes: -------")
        print(localNotes.count)
        print(getLocationNumber(allNotes: localNotes))
        print(getPhotoNumber(allNotes: localNotes))
        print("Cloud notes: -------")
        print(getInfoNumber().locationCount)
        print("--------------------")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    func getInfoNumber() -> (noteCount: Int, locationCount: Int, photoCount: Int) {
        var num = 0
        
        guard let userID = Auth.auth().currentUser?.uid else {
            displayMessage("Cannot download unitl logged in", "Error")
            return (0,0,0)
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
                //return (noteNum, locationNum, photoNum)
                //self.userLabel.text = String(noteNum)
                num = noteNum
            }
        }
        
        return (0,0,0)
    }
    

    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
