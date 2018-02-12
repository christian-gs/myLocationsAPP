//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationController: UIViewController, CLLocationManagerDelegate  {
    
    private var messageLabel = UILabel()
    private var latitudeTextLabel = UILabel()
    private var longitudeTextLabel = UILabel()
    private var latitudeValueLabel = UILabel()
    private var longitudeValueLabel = UILabel()
    private var addressLabel = UILabel()
    private var tagButton = UIButton()
    private var getButton = UIButton()

    private let locationManager = CLLocationManager()
    private var location: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        edgesForExtendedLayout = []

        messageLabel.text = "(Message Label)"
        messageLabel.textAlignment = .center
        latitudeTextLabel.text = "Latitude: "
        latitudeTextLabel.textAlignment = .left
        latitudeValueLabel.text = "111.111"
        latitudeValueLabel.textAlignment = .right
        longitudeTextLabel.text = "Longitude: "
        longitudeTextLabel.textAlignment = .left
        longitudeValueLabel.text = "222.111"
        longitudeValueLabel.textAlignment = .right
        addressLabel.text = "Address goes here"
        addressLabel.textAlignment = .left
        addressLabel.numberOfLines = 0
        tagButton.setTitle("Tag Location", for: .normal)
        tagButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        tagButton.isHidden = true
        getButton.setTitle("Get My Location", for: .normal)
        getButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        getButton.addTarget(self, action: #selector(getLocation), for: .touchUpInside)

        for label in [messageLabel, latitudeTextLabel, latitudeValueLabel, longitudeTextLabel,
                      longitudeValueLabel, addressLabel, tagButton, getButton] as [UIView] {
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
        }

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
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

            getButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
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
        //set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }

    func updateLabels() {
        if let location = location {
            latitudeValueLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeValueLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            latitudeValueLabel.text = ""
            longitudeValueLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"
        } }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        location = newLocation
        updateLabels()
    }

    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }

}

