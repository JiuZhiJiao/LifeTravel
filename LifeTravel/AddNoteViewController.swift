//
//  AddNoteViewController.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 5/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AddNoteViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DatabaseListener {
    
    @IBOutlet weak var addDate: UILabel!
    @IBOutlet weak var addLocation: UILabel!
    @IBOutlet weak var addContent: UITextView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation = CLLocation()
    weak var databaseController: DatabaseProtocol?
    
    var image: UIImage?
    
    // Firebase Ref
    var imageRef = Firestore.firestore().collection("images")
    var storageReference = Storage.storage().reference()
    
    var noteDate: String?
    var noteLocation: String?
    var noteContent: String?
    var notePhoto: String?
    var noteLat: Double?
    var noteLong: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // location
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        
        let authorisationStatus = CLLocationManager.authorizationStatus()
        if authorisationStatus != .authorizedWhenInUse {
            if authorisationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        addContent.delegate = self
        addDate.text = currentDate()
        
        // observe keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // databaseController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    // keyboard methods
    @objc func keyboardWillShow(_ notification: Notification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 310, right: 0.0)
        self.addContent.contentInset = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0.0,left: 0.0,bottom: 0.0,right: 0.0)
        self.addContent.contentInset = contentInsets
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        locationManager.stopUpdatingLocation()
    }
    
    // hide keyboard when click blank area
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addContent.resignFirstResponder()
        self.view.endEditing(false)
    }
    
    // MARK: - CLLocation Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count-1] as CLLocation
        currentLocation = location
        
        if location.horizontalAccuracy > 0 {
            // set note location
            self.noteLat = location.coordinate.latitude
            self.noteLong = location.coordinate.longitude
        }
        
        let geocoder = CLGeocoder()
        var place:CLPlacemark?
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Cannot get the address")
                return
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count > 0 {
                place = placemarks![0] as CLPlacemark
                print("address: \(place?.name! ?? "No Address")")
                // set add location name
                self.addLocation.text = place?.name! ?? "No Address"
            } else {
                print("Cannot get the address")
            }
        })
    }
    
    // MARK: - Database Listener Functions
    func onNoteListChange(change: DatabaseChange, notes: [Note]) {
        
    }
    
    // MARK: - Storyboard Button Methods
    
    @IBAction func cancelAdd(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAdd(_ sender: Any) {
        // upload the photo taken or selected by user
        if self.image != nil {
            let img = self.image
            //let date = UInt(Date().timeIntervalSince1970)
            //      let filename = "\(date).jpg"
            guard let data = img?.jpegData(compressionQuality: 0.2) else {
                displayMessage("Image can not be compressed.", "Error")
                return
            }
            
            let imgRef = storageReference.child("images")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            imgRef.putData(data, metadata: metadata){(meta, error) in
                if error != nil {
                    self.displayMessage("Could not upload image to firebase", "Error")
                } else {
                    imgRef.downloadURL{(url, error) in
                        guard let downloadURL = url else {
                            print("Download URL not found")
                            return
                        }
                        
                        self.imageRef.document("\(data)").setData(["url":"\(downloadURL)"])
                        self.notePhoto = downloadURL.absoluteString
                        print(self.notePhoto!)
                        self.saveNote()
                    }
                }
            }
        } else {
            self.notePhoto = ""
            self.saveNote()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // save note
    func saveNote() {
        noteDate = addDate.text
        noteLocation = addLocation.text
        noteContent = addContent.text
        //setPhoto()
        
        print(noteDate)
        print(noteLocation)
        print(noteLat)
        print(noteLong)
        print(notePhoto)
        print(noteContent)
        
        let _ = databaseController?.addNote(date: noteDate!, location: noteLocation!, lat: noteLat!, long: noteLong!, photo: notePhoto!, content: noteContent!)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        picker.allowsEditing = false
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - UIImage Picker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.image = pickedImage
            print("photo taken")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let high = textView.frame.height - 330
        let rect = CGRect(origin: textView.frame.origin, size: CGSize(width: textView.frame.width, height: high))
        textView.frame = rect
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        addContent.resignFirstResponder()
        addContent.frame = view.frame
    }
    
    
    
    // MARK: - Other Methods
    
    // get current date
    func currentDate() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd"
        let time = dateformatter.string(from: Date())
        return time
    }
    
    // display message
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
