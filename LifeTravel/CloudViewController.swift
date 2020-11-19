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

class CloudViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var userReference = Firestore.firestore().collection("users")
    var storageReference = Storage.storage().reference()
    var notesRef : CollectionReference?
    var firebaseListener: ListenerRegistration?
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let firebase = Firestore.firestore()
        
        
        // database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

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
                //delete all notes on the cloud
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
