//
//  AddNoteViewController.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 5/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit
import CoreLocation

class AddNoteViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var addDate: UILabel!
    @IBOutlet weak var addLocation: UILabel!
    @IBOutlet weak var addContent: UITextView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation = CLLocation()
    
    var noteDate: String?
    var noteLocation: String?
    var noteContent: String?
    var notePhoto: Data?
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
    
    // MARK: - Storyboard Button Methods
    
    @IBAction func cancelAdd(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAdd(_ sender: Any) {
        noteDate = addDate.text
        noteLocation = addLocation.text
        noteContent = addContent.text
        
        navigationController?.popViewController(animated: true)
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
