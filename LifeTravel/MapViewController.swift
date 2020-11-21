//
//  MapViewController.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, DatabaseListener {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var zoomOnce = true
    
    var allNote = [Note]()
    var locationList = [LocationAnnotation]()
    var selectedNote: Note?
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        */
        
        // set map
        self.mapView.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        
        let authorisationStatus = CLLocationManager.authorizationStatus()
        if authorisationStatus != .authorizedAlways {
            if authorisationStatus == .notDetermined {
                locationManager.requestAlwaysAuthorization()
            }
        }
        
        self.mapView.showsUserLocation = true
        /*
        let buttonItem = MKUserTrackingButton(mapView: mapView)
        buttonItem.layer.backgroundColor = UIColor.white.withAlphaComponent(0.8).cgColor
        buttonItem.layer.borderColor = UIColor.white.cgColor
        buttonItem.layer.borderWidth = 1
        buttonItem.layer.cornerRadius = 5
        buttonItem.isHidden = false
        view.addSubview(buttonItem)
        buttonItem.frame = .init(x: view.frame.width - 50, y: view.frame.height - 60, width: 40, height: 40)
        */
        
        // set data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Center map on user current location
        self.mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        
        databaseController?.addListener(listener: self)
        setAnnotations()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        
        // set the style of the annotation
        let identifier = "marker"
        var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if markerView == nil {
            markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            let location = annotation as! LocationAnnotation
           
            //let location = annotation as! LocationAnnotation
            markerView?.canShowCallout = true
            markerView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            
            
            // add image at the leftCalloutAccessoryView
            let urlString = location.note?.photo
            if urlString != ""{
                let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
                setImage(urlString: urlString!, annoImage: imageView)
                markerView?.leftCalloutAccessoryView = imageView
            }
            
        }
        
        return markerView
    }
    
    // click on one annotaion to show detail
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! LocationAnnotation
        
        // show detail of selected annotation
        selectedNote = annotation.note
        self.performSegue(withIdentifier: "showDetailMapSegue", sender: annotation)
        /*
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        detailVC.note = selectedNote
        navigationController?.show(detailVC, sender: nil)
        */
    }
    
    // MARK: - CLLocationManager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            //(currentLocation?.latitude)
            let currentRegion = MKCoordinateRegion(center: currentLocation!, latitudinalMeters: 500, longitudinalMeters: 500)
            
            if zoomOnce == true {
                self.mapView.setRegion(currentRegion, animated: true)
                zoomOnce = !zoomOnce
            }
            
        }
    }
    
    // MARK: - Database Listener Delegate
    func onNoteListChange(change: DatabaseChange, notes: [Note]) {
        allNote = notes
        
        // reset annotations
        self.mapView.removeAnnotations(locationList)
        for location in locationList {
            stopMonitoring(location: location)
        }
        locationList.removeAll()
        setAnnotations()
        print(allNote.count)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailMapSegue" {
            let destination = segue.destination as! DetailViewController
            destination.note = selectedNote
        }
    }
    
    // set all annotations
    func setAnnotations() {
        for note in allNote {
            let location = LocationAnnotation(note: note)
            locationList.append(location)
            mapView.addAnnotation(location)
            //start monitor ~~
            startMonitoring(location: location)

            
        }
    }
    
    
    // Download Image by using DispathQueue
    func setImage(urlString: String, annoImage: UIImageView?) {
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    annoImage?.image = image
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Geofence
    
    func region(with location: LocationAnnotation) -> CLCircularRegion {
        let region = CLCircularRegion(center: location.coordinate, radius: 100, identifier: location.title!)
        region.notifyOnEntry = true
        return region
    }

    func startMonitoring(location: LocationAnnotation) {
      let fenceRegion = region(with: location)
      locationManager.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoring(location: LocationAnnotation) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == location.title else {
                continue
            }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }

}
