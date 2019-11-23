//
//  ViewController.swift
//  RubberSideDown
//
//  Created by Graham Nelson on 11/2/19.
//  Copyright © 2019 Graham Nelson. All rights reserved.
//
import UIKit
import CoreMotion
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var calibrateButton: UIButton!
    @IBOutlet var leanLabel: UILabel!
    @IBOutlet var crashLabel: UILabel!
    @IBOutlet var instructionsLabel: UILabel!
    @IBOutlet var riderImage: UIImageView!
    @IBOutlet var endButton: UIButton!
    
    let locationManager = CLLocationManager()
    let motion = CMMotionManager()
    var timer: Timer!
    
    var baseY = 0.0
    var needBaseGyro = false
    var hasCrashed = false
    
    var crashSensetivity = 1.1
    
    let settings = UserDefaults.standard
    let Crash = CrashEvent()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsLabel.isHidden = false
        //prepare for location updates
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        resetCrashFormatting()
        //set center of rotation for rider sprite
        riderImage.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        riderImage.isHidden = true
    }
    
    //resets when view is closed
      override func viewDidDisappear(_ animated: Bool) {
          super.viewDidDisappear(animated)
          resetCrashFormatting()
          motion.stopDeviceMotionUpdates()
          self.hasCrashed = false
      }
    
    //displays warning if user has not updated settings
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if emptyFields(){
            emptyFieldsWarning()
        }
    }
    
    //returns true if either rideName or contact number fields are empty
    func emptyFields() -> Bool{
        if settings.string(forKey: "riderName") == nil{
            return true
        } else if settings.string(forKey: "contact0Number") == nil &&
            settings.string(forKey: "contact1Number") == nil &&
            settings.string(forKey: "contact2Number") == nil {
            return true
        }
        return false
    }
    
    //prompts user to update settings
    func emptyFieldsWarning(){
        let alert = UIAlertController(title: "Update Your Settings", message: "You have settings that have not been updated. Open the settings menu in the upper left-hand corner to update your name and add contacts", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    //button used to either calibrate base y position or cancel crash countdown
    @IBAction func calibrate(_ sender: UIButton) {
        setCrashSensetivity()
        if !hasCrashed{
            needBaseGyro = true
            instructionsLabel.isHidden = true
            riderImage.isHidden = false
            endButton.isHidden = false
            readGyro()
        } else {
            self.Crash.stopTimer()
            resetCrashFormatting()
            motion.stopDeviceMotionUpdates()
            instructionsLabel.isHidden = false
            riderImage.isHidden = true
            self.riderImage.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            self.hasCrashed = false
        }
    }
    
    //button that allows users to end motion updates and reset app
    @IBAction func endRide(_ sender: UIButton) {
        self.Crash.stopTimer()
        resetCrashFormatting()
        motion.stopDeviceMotionUpdates()
        instructionsLabel.isHidden = false
        riderImage.isHidden = true
        self.riderImage.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        self.hasCrashed = false
    }
    
    
    //begins reading device motion and checks for crash case
    func readGyro(){
        motion.deviceMotionUpdateInterval = 0.1
        motion.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { data, error in
            if let data = self.motion.deviceMotion {
                //read in y pos, set relativeY based on base y calibrated value
                let y = data.attitude.roll
                if self.needBaseGyro {
                    self.baseY = y
                    self.needBaseGyro = false
                }
                //handle animation of rider image
                self.rotateRiderImage(yPos: y - self.baseY)
                
                let relativeY = abs(y - self.baseY)
                self.leanLabel.text = "Lean Angle: \(Int((relativeY * 180) / .pi))°"
                //check if user has crashed
                if relativeY > self.crashSensetivity{
                    self.handleCrash()
                } else {
                    //case for initial update after device is righted
                    if self.hasCrashed{
                        self.Crash.stopTimer()
                        self.resetCrashFormatting()
                        self.endButton.isHidden = false
                        self.hasCrashed = false
                    }
                }
            }
        })
    }
    
    //handles crash case
    func handleCrash(){
        //case for initial crash update
        if !self.hasCrashed{
            self.hasCrashed = true
            self.setCrashFormatting()
            self.Crash.startTimer()
        }
        self.endButton.isHidden = true
        self.flashScreen()
        let time = self.Crash.getCountdownTime()
        self.crashLabel.text = "Sending Emergency Message in: \(time)s"
        //reset app when timer reaches 0
        if time == 0 {
            Crash.sendEmergencyMessage()
            messageSentAlert()
            self.resetCrashFormatting()
            self.hasCrashed = false
            motion.stopDeviceMotionUpdates()
            instructionsLabel.isHidden = false
            riderImage.isHidden = true
            self.riderImage.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }
    }
    
    //prevent rider image from rotating past 90 degrees in either direction
    func rotateRiderImage(yPos: Double){
        if yPos > .pi/2 {
            self.riderImage.transform = CGAffineTransform(rotationAngle: .pi/2)
        } else if yPos < -.pi/2{
            self.riderImage.transform = CGAffineTransform(rotationAngle: -.pi/2)
        } else {
            self.riderImage.transform = CGAffineTransform(rotationAngle: CGFloat(yPos))
        }
    }
    
    //presents alert that tells user that emergency message has been sent
    //prompts them to send OK message
    func messageSentAlert(){
        let alert = UIAlertController(title: "Emergency Message Sent", message: "Emergency message has been sent to your contacts. Press \"Send OK\" to tell them you're alright", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Send OK", style: .default, handler: { action in self.Crash.sendOKMessage()}))
        self.present(alert, animated: true)
    }

    //sets formating of UI elements when a crash has been detected
    func setCrashFormatting(){
        endButton.isHidden = true
        calibrateButton.backgroundColor = UIColor.systemRed
        calibrateButton.setTitle("Cancel", for: .normal)
    }
    
    //resets formatting of UI elements after crash has been dismissed
    func resetCrashFormatting(){
        calibrateButton.backgroundColor = UIColor.systemGreen
        calibrateButton.setTitle("Calibrate", for: .normal)
        self.view.backgroundColor = UIColor.black
        leanLabel.text = ""
        self.crashLabel.text = ""
        calibrateButton.layer.cornerRadius = 25
        endButton.isHidden = true;
        endButton.layer.cornerRadius = 25
        endButton.layer.borderWidth = 1
        endButton.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    //sets the lean angle that will trigger a crash case based on bike type
    func setCrashSensetivity(){
        let type = settings.integer(forKey: "bikeType")
        switch (type){
            case 0: crashSensetivity = 1.0 //Touring
            case 1: crashSensetivity = 1.2 //Dual Sport
            case 2: crashSensetivity = 1.1 //Naked
            case 3: crashSensetivity = 1.2 //Sport
            default: crashSensetivity = 1.1
        }
    }
    
    //update user location to be used in emergency message
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          let lastLocation = locations.last!
          let geocoder = CLGeocoder()
          geocoder.reverseGeocodeLocation(lastLocation, completionHandler: {(placemarks, error) in
              if error == nil {
                  let userLocation = placemarks![0]
                  let locationStr = "\(userLocation.subThoroughfare ?? "") \(userLocation.thoroughfare ?? ""), \(userLocation.locality ?? "") \(userLocation.administrativeArea ?? "")"
                  self.Crash.setUserLocation(location: locationStr)
              }
          })
      }
    
    //flashes screen during crash case
    func flashScreen(){
        if self.view.backgroundColor == UIColor.black{
            self.view.backgroundColor = UIColor.darkGray
        } else {
            self.view.backgroundColor = UIColor.black
        }
    }    
}

