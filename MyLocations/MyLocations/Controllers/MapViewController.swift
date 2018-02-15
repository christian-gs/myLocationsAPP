//
//  MapViewController.swift
//  MyLocations
//
//  Created by Christian on 2/14/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate{

    let mapView = MKMapView()
    var locations = [Location]()
    //user location
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private var updatingLocation = false
    private var lastLocationError: Error?
    //core data
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Map"

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Locations", style: .plain, target: self, action: #selector(showLocations))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "User", style: .plain, target: self, action: #selector(showUser))

        mapView.frame = view.frame
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true

        view.addSubview(mapView)
    }

    override func viewDidAppear(_ animated: Bool) {
        updateLocations()
        if !locations.isEmpty {
            showLocations()
        }
    }

    @objc func showUser() {
            getLocation()
    }

    func zoomToUser(location: CLLocation) {
        let region = MKCoordinateRegionMakeWithDistance( location.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }

    @objc func getLocation() {
        //ask permission for user location  (also had to add "NSLocationWhenInUseUsageDescription" to Info.plist file)
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        // if permission denied show popup alert
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        //start/stop searching for user location
        if updatingLocation {
            stopLocationManager()
        } else {
            userLocation = nil
            lastLocationError = nil
            startLocationManager()
        }
    }

    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }

    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }

    @objc func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }

    func updateLocations() {
        mapView.removeAnnotations(locations)
        let entity = Location.entity()
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }

    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
            let region: MKCoordinateRegion
            switch annotations.count {
            case 0:
                region = MKCoordinateRegionMakeWithDistance( mapView.userLocation.coordinate, 1000, 1000)
            case 1:
                let annotation = annotations[annotations.count - 1]
                region = MKCoordinateRegionMakeWithDistance( annotation.coordinate, 1000, 1000)
            default:
                var topLeft = CLLocationCoordinate2D(latitude: -90,  longitude: 180)
                var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
                for annotation in annotations {
                    topLeft.latitude = max(topLeft.latitude,  annotation.coordinate.latitude)
                    topLeft.longitude = min(topLeft.longitude,  annotation.coordinate.longitude)
                    bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                    bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
                }
                let center = CLLocationCoordinate2D(
                    latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
                    longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)
                let extraSpace = 1.1
                let span = MKCoordinateSpan( latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
                    longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
                region = MKCoordinateRegion(center: center, span: span)
            }
            return mapView.regionThatFits(region)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        // only update location if its been at least 5 seconds from last update
        guard newLocation.timestamp.timeIntervalSinceNow > -5 else { return }
        // filter out invalid location updates
        guard newLocation.horizontalAccuracy > 0 else { return }


        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = userLocation {
            distance = newLocation.distance(from: location)
        }

        // only update if current location hasnt been retrieved or the new update is more accurate
        if userLocation == nil || userLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            userLocation = newLocation
            zoomToUser(location: userLocation!)
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
            }
        }
        else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(userLocation!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
            }
        }
    }

    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }

    @objc func showLocationDetails(_ sender: UIButton) {
        //retrive previously stored location index from buttons tag
        let index = Int(sender.tag)
        let locationDetailsViewController = LocationDetailsViewController(locationToEdit: locations[index])
        locationDetailsViewController.managedObjectContext = self.managedObjectContext
        navigationController?.pushViewController(locationDetailsViewController, animated: true)
    }

}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) ->  MKAnnotationView? {
        // return immediatly if pin is not of type Location
        guard annotation is Location else {
            return nil
        }

        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView( withIdentifier: identifier)
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            // customise pin
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            // add button to bin
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }
        // add location index to the buttons tag, so we can retrive location index when button pushed (showLocationDetails method)
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
        }
        return annotationView
    }

}
