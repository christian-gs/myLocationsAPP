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
import AudioToolbox

class CurrentLocationController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate  {

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
    //animations
    private var detailsView = UIView()
    var logoVisible = true
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "camera"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        button.frame = CGRect(x: view.center.x , y: view.center.y, width: 250 , height: 250)
        button.center.x = self.view.bounds.midX
        button.center.y = view.center.y - 50
        return button
    }()
    //sound
    var soundID: SystemSoundID = 0
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
        tagButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25.0)
        getButton.setTitle("Get My Location", for: .normal)
        getButton.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        getButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25.0)
        getButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        detailsView.backgroundColor = .clear

        for v in [messageLabel, latitudeTextLabel, latitudeValueLabel, longitudeTextLabel,
                      longitudeValueLabel, addressLabel, tagButton] as! [UIView]{
            v.translatesAutoresizingMaskIntoConstraints = false
            detailsView.addSubview(v)
        }

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 30),
            messageLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor),
            messageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),

            latitudeTextLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 40),
            latitudeTextLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 20),
            latitudeTextLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: 20),

            latitudeValueLabel.topAnchor.constraint(equalTo: latitudeTextLabel.topAnchor),
            latitudeValueLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant:-20),

            longitudeTextLabel.topAnchor.constraint(equalTo: latitudeTextLabel.bottomAnchor, constant: 10),
            longitudeTextLabel.leadingAnchor.constraint(equalTo: latitudeTextLabel.leadingAnchor),
            longitudeTextLabel.trailingAnchor.constraint(equalTo: latitudeTextLabel.trailingAnchor),

            longitudeValueLabel.topAnchor.constraint(equalTo: longitudeTextLabel.topAnchor),
            longitudeValueLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -20),

            addressLabel.topAnchor.constraint(equalTo: longitudeTextLabel.bottomAnchor, constant: 20),
            addressLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: 20),
            addressLabel.heightAnchor.constraint(equalToConstant: 50),

            tagButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 30),
            tagButton.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor),
            tagButton.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor)
            ])

        for v in  [detailsView, getButton] {
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }

        NSLayoutConstraint.activate([
            detailsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            getButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])

        //prep animation
        view.addSubview(logoButton)
        detailsView.isHidden = true

        loadSoundEffect("sounds/sound.mp3")
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
        //hide logo
        if logoVisible {
            hideLogoView()
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
                showLogoView()
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }


    func showLogoView() {
        if !logoVisible {
            logoVisible = true
            view.addSubview(logoButton)

            //move logo off left side of screen
            logoButton.center.x = -view.bounds.size.width
            logoButton.center.y = logoButton.center.y


            //animate logo sliding in
            let logoMover = CABasicAnimation(keyPath: "position")
            logoMover.isRemovedOnCompletion = false
            logoMover.fillMode = kCAFillModeForwards
            logoMover.duration = 0.5
            logoMover.fromValue = NSValue(cgPoint: logoButton.center)
            logoMover.toValue = NSValue(cgPoint: CGPoint(x: view.bounds.midX, y: view.center.y - 50))
            logoMover.timingFunction = CAMediaTimingFunction( name: kCAMediaTimingFunctionEaseIn)
            logoButton.layer.add(logoMover, forKey: "logoMover")

            //animate logo rotating
            let logoRotator = CABasicAnimation(keyPath:"transform.rotation.z")
            logoRotator.isRemovedOnCompletion = false
            logoRotator.fillMode = kCAFillModeForwards
            logoRotator.duration = 0.5
            logoRotator.fromValue = 0.0
            logoRotator.toValue = 2 * Double.pi
            logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            logoButton.layer.add(logoRotator, forKey: "logoRotator")

            //animate detailsView slideing out
            let panelMover = CABasicAnimation(keyPath: "position")
            panelMover.isRemovedOnCompletion = false
            panelMover.fillMode = kCAFillModeForwards
            panelMover.duration = 0.6
            panelMover.fromValue = NSValue(cgPoint: detailsView.center)
            panelMover.toValue = NSValue(cgPoint:CGPoint(x: view.bounds.midX * 3, y: detailsView.center.y))
            panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            panelMover.delegate = self
            detailsView.layer.add(panelMover, forKey: "panelMover")

            logoButton.center.x = self.view.bounds.midX
            logoButton.center.y = view.center.y - 50
        }
    }

    func hideLogoView() {
        guard logoVisible else { return }

        logoVisible = false
        detailsView.isHidden = false

        //move details view off to right side of screen
        detailsView.center.x = view.bounds.size.width * 2

        //animate detailsView slideing in
        let centerX = view.bounds.midX
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: detailsView.center)
        panelMover.toValue = NSValue(cgPoint:CGPoint(x: centerX, y: detailsView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        detailsView.layer.add(panelMover, forKey: "panelMover")

        //animate logo sliding out
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction( name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")

        //animate logo rotating
        let logoRotator = CABasicAnimation(keyPath:"transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")

        detailsView.center.x = centerX
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
        let spinnerTag = 1000
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
                spinner.center = messageLabel.center
                spinner.center.y += 30
                spinner.startAnimating()
                spinner.tag = spinnerTag
                detailsView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Location", for: .normal)
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
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

    // MARK:- Sound effects
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound: \(path)")
            }
        }
    }
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }

    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
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
                        if self.placemark == nil {
                            self.playSoundEffect()
                        }
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

    // MARK:- Animation Delegate Methods
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        detailsView.layer.removeAllAnimations()
        logoButton.layer.removeAllAnimations()

        if logoVisible {
            detailsView.isHidden = true
        }
        else if !detailsView.isHidden {
            logoButton.removeFromSuperview()
        }

    }

}

