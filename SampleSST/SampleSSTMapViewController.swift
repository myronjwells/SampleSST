//
//  SampleSSTMapViewController.swift
//  SampleSST
//
//  Created by Myron Wells on 3/9/18.
//  Copyright © 2018 Myron Wells. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

extension Double {
    
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return ((self * divisor).rounded() / divisor).magnitude
    }
}

class SampleSSTMapViewController: UIViewController, CLLocationManagerDelegate  {
    
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var currentSelectedCityStateLabel: UILabel?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeCoords: UILabel!
    @IBOutlet weak var longitudeCoords: UILabel!
    
    
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        determineCurrentLocation()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        //Initialize the long press gesture and call the function once activated
        let longpressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addMapAnnotationOnLongPress(press:)))
        longpressGestureRecognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longpressGestureRecognizer)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        determineCurrentLocation()
    }
    
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
    
    
    
    @objc func addMapAnnotationOnLongPress(press:UILongPressGestureRecognizer) {
        
        
        //For adding annotations by longpressing
        
        if press.state == .began {
            let annotation = MKPointAnnotation()
            
            //make sure to remove any annotations before adding a new one to prevent multiple
            removePreviousAnnotations()
            
            //get location of pressed position on map and convert to it's coordinant location
            let location = press.location(in: mapView)
            let coordinants = mapView.convert(location, toCoordinateFrom: mapView)
            annotation.coordinate = coordinants
            
            //add annotation
            mapView.addAnnotation(annotation)
            
            //update labels
            self.updateCoordLabels(coord: annotation.coordinate)
            
        }
        
        
    }
    
    func removePreviousAnnotations() {
        
        let previousAnnotations = mapView.annotations
        mapView.removeAnnotations(previousAnnotations)
    }
    
    
    
    @objc func addMapAnnotationByLocation(location:CLLocation) {
        
        let annotation: MKPointAnnotation = MKPointAnnotation()
        
        removePreviousAnnotations()
        
        annotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        mapView.addAnnotation(annotation)
        self.updateCoordLabels(coord: annotation.coordinate)
        
        
    }
    
    
    
    
    func updateCoordLabels(coord: CLLocationCoordinate2D) {
        
        
        let lat = coord.latitude
        let long = coord.longitude
        
        
        //Format coordinant string and add to label
        latitudeCoords.text = "latitude \(lat.roundToPlaces(places: 4))° \(lat < 0 ? "S":"N")"
        longitudeCoords.text = "longitude \(long.roundToPlaces(places: 4))° \(lat < 0 ? "W":"E")"
        
        // get address for touch coordinates.
        let geoCoder = CLGeocoder()
        let coordinateLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        geoCoder.reverseGeocodeLocation(coordinateLocation, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Looking up Annotations address has shown the following error: \(String(describing: error))")
                return
            }
            
            if(placemarks?.count)! > 0 {
                
                let pm = placemarks?[0] as CLPlacemark!
                
                let city = pm?.locality
                let state = pm?.administrativeArea
                
                
                self.currentSelectedCityStateLabel?.text = "\(city != nil ? "\(city!), " : "") \(state != nil ? "\(state!)":"")"
                
                
                
            }
            
        })
        
        
        
    }
    
    
    // Delegate Method for Core Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50))
        mapView.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
        addMapAnnotationByLocation(location: userLocation)
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        manager.stopUpdatingLocation()
    }
    
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error \(error)")
    }
    
    
}

