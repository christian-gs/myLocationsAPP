//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationController: UIViewController, CLLocationManagerDelegate  {

    //UIViews
    private var messageLabel = UILabel()
    private var latitudeTextLabel = UILabel()
    private var longitudeTextLabel = UILabel()
    private var latitudeValueLabel = UILabel()
    private var longitudeValueLabel = UILabel()
    private var addressLabel = UILabel()
    private var tagButton = UIButton()
    private var getButton = UIButton()
    private var imageView = UIImageView()
    //user location
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    private var updatingLocation = false
    private var lastLocationError: Error?
    //reverse geocoding (turn lat & longitude to an actual address)
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    // used to time out a location request if it taskes to long
    var timer: Timer?
    //coreData
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Current Location"
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        messageLabel.textAlignment = .center
        latitudeTextLabel.text = "Latitude: "
        latitudeTextLabel.textAlignment = .left
        latitudeValueLabel.text = ""
        latitudeValueLabel.textAlignment = .right
        latitudeValueLabel.font = UIFont.boldSystemFont(ofSize: 17)
        longitudeTextLabel.text = "Longitude: "
        longitudeTextLabel.textAlignment = .left
        longitudeValueLabel.text = ""
        longitudeValueLabel.textAlignment = .right
        longitudeValueLabel.font = UIFont.boldSystemFont(ofSize: 17)
        addressLabel.textAlignment = .left
        addressLabel.numberOfLines = 0
        tagButton.setTitle("Tag Location", for: .normal)
        tagButton.isHidden = true
        tagButton.addTarget(self, action: #selector(openLocationDetailsViewController), for: .touchUpInside)
        getButton.setTitle("Get My Location", for: .normal)
        getButton.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        imageView.image = #imageLiteral(resourceName: "camera")

        for v in [messageLabel, latitudeTextLabel, latitudeValueLabel, longitudeTextLabel,
                      longitudeValueLabel, addressLabel, tagButton, getButton, imageView] as! [UIView]{
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            latitudeTextLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 40),
            latitudeTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            latitudeTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),

            latitudeValueLabel.topAnchor.constraint(equalTo: latitudeTextLabel.topAnchor),
            latitudeValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-20),

            longitudeTextLabel.topAnchor.constraint(equalTo: latitudeTextLabel.bottomAnchor, constant: 10),
            longitudeTextLabel.leadingAnchor.constraint(equalTo: latitudeTextLabel.leadingAnchor),
            longitudeTextLabel.trailingAnchor.constraint(equalTo: latitudeTextLabel.trailingAnchor),

            longitudeValueLabel.topAnchor.constraint(equalTo: longitudeTextLabel.topAnchor),
            longitudeValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            addressLabel.topAnchor.constraint(equalTo: longitudeTextLabel.bottomAnchor, constant: 20),
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
            addressLabel.heightAnchor.constraint(equalToConstant: 50),

            tagButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 30),
            tagButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            imageView.bottomAnchor.constraint(equalTo: getButton.topAnchor, constant: -50),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 200),

            getButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }

    @objc func openLocationDetailsViewController() {
        let locationDetailsViewController = LocationDetailsViewController(location: self.location!, address: addressLabel.text!)
        locationDetailsViewController.managedObjectContext = managedObjectContext // coreData
        navigationController?.pushViewController(locationDetailsViewController, animated: true)
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
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
    }

    func updateLabels() {
        if let location = location {
            latitudeValueLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeValueLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeValueLabel.text = ""
            longitudeValueLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }

    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        if let s = placemark.thoroughfare {
            line1 += s }
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s }
        return line1 + "\n" + line2
    }

    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }

    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            //set timer for 60 seconds after which the app will stop attempting to retrieve user location
            timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                         selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }

    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }

    @objc func didTimeOut() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError( domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        // only update location if its been at least 5 seconds from last update
        guard newLocation.timestamp.timeIntervalSinceNow > -5 else { return }
        // filter out invalid location updates
        guard newLocation.horizontalAccuracy >= 0 else { return }


        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }

        // only update if current location hasnt been retrieved or the new update is more accurate
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            updateLabels()
            // Reverse Geocoding
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) in
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        }
        else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
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

}

