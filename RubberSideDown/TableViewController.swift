//
//  TableViewController.swift
//  RubberSideDown
//
//  Created by Graham Nelson on 11/11/19.
//  Copyright © 2019 Graham Nelson. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet var riderNameField: UITextField!

    @IBOutlet var bikeMakeField: UITextField!
    @IBOutlet var bikeModelField: UITextField!
    @IBOutlet var bikeColorField: UITextField!
    @IBOutlet var bikeTypeSelector: UISegmentedControl!
    
    @IBOutlet var contact0NameField: UITextField!
    @IBOutlet var contact0NumberField: UITextField!
    
    @IBOutlet var contact1NameField: UITextField!
    @IBOutlet var contact1NumberField: UITextField!
    
    @IBOutlet var contact2NameField: UITextField!
    @IBOutlet var contact2NumberField: UITextField!
    
    @IBOutlet var countdownTimeLabel: UILabel!
    @IBOutlet var countdownTimeSlider: UISlider!
    
    let settings = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateRiderAndBike()
        populateContact(contactNumber: 0, nameField: contact0NameField, numberField: contact0NumberField)
        populateContact(contactNumber: 1, nameField: contact1NameField, numberField: contact1NumberField)
        populateContact(contactNumber: 2, nameField: contact2NameField, numberField: contact2NumberField)
        populateCountdown()
    }
    
    //fill rider and bike fields with values from UserDefaults
    //if nil, populate with empty string
    func populateRiderAndBike(){
        if let rn = settings.string(forKey: "riderName"){
            riderNameField.text = rn
        } else {
            settings.set("", forKey: "riderName")
        }
        if let bmk = settings.string(forKey: "bikeMake"){
            bikeMakeField.text = bmk
        } else {
            settings.set("", forKey: "bikeMake")
        }
        if let bmd = settings.string(forKey: "bikeModel"){
            bikeModelField.text = bmd
        } else {
            settings.set("", forKey: "bikeModel")
        }
        if let bc = settings.string(forKey: "bikeColor"){
            bikeColorField.text = bc
        } else {
            settings.set("", forKey: "bikeColor")
        }
        bikeTypeSelector.selectedSegmentIndex = settings.integer(forKey: "bikeType")
    }
    
    //fill contact fields with values from UserDefaults
    func populateContact(contactNumber: Int, nameField: UITextField, numberField: UITextField){
        if let nm = settings.string(forKey: "contact\(contactNumber)Name"){
            nameField.text = nm;
        }
        if let num = settings.string(forKey: "contact\(contactNumber)Number"){
            numberField.text = num;
        }
    }
    
    //fill countdown field with value from UserDefaults
    func populateCountdown(){
        let countdown = settings.integer(forKey: "countdownTime")
        if countdown >= 10 && countdown <= 60 {
            countdownTimeSlider.setValue(Float(countdown), animated: true)
            countdownTimeLabel.text = "\(countdown)s"
        }
    }
    
    func invalidPhoneWarning(){
        let alert = UIAlertController(title: "Invalid Phone Number", message: "Enter a valid 10-digit phone number with no dashes or spaces", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func riderNameUpdate(_ sender: UITextField) {
        settings.set(sender.text, forKey: "riderName")
    }
    
    @IBAction func bikeMakeUpdate(_ sender: UITextField) {
        settings.set(sender.text, forKey: "bikeMake")
    }
    
    @IBAction func bikeModelUpdate(_ sender: UITextField) {
        settings.set(sender.text, forKey: "bikeModel")
    }
    
    @IBAction func bikeColorUpdate(_ sender: UITextField) {
        settings.set(sender.text, forKey: "bikeColor")
    }
    
    @IBAction func bikeTypeUpdate(_ sender: UISegmentedControl) {
        settings.set(sender.selectedSegmentIndex, forKey: "bikeType")
        print(sender.selectedSegmentIndex)
    }
    
    
    @IBAction func contact0NameUpdate(_ sender: UITextField) {
        settings.set(sender.text, forKey: "contact0Name")
    }
    
    @IBAction func contact0NumberUpdate(_ sender: UITextField) {
        if sender.text?.count == 10 || sender.text?.count == 0{
            settings.set(sender.text, forKey: "contact0Number")
        } else if sender.text?.count != 0{
            settings.set("", forKey: "contact0Number")
            invalidPhoneWarning()
        }
    }
    
    @IBAction func contact1NameUpdate(_ sender: UITextField) {
        settings.set(sender.text, forKey: "contact1Name")
    }
    
    @IBAction func contact1NumberUpdate(_ sender: UITextField) {
        if sender.text?.count == 10 || sender.text?.count == 0 {
            settings.set(sender.text, forKey: "contact1Number")
        } else if sender.text?.count != 0{
            settings.set("", forKey: "contact1Number")
            invalidPhoneWarning()
        }
    }
    
    @IBAction func contact2NameUpdate(_ sender: UITextField) {
        settings.set(sender.text, forKey: "contact2Name")
    }
    
    @IBAction func contact2NumberUpdate(_ sender: UITextField) {
        if sender.text?.count == 10 || sender.text?.count == 0 {
            settings.set(sender.text, forKey: "contact2Number")
        } else if sender.text?.count != 0{
            settings.set("", forKey: "contact2Number")
            invalidPhoneWarning()
        }
    }
    
    @IBAction func countdownSliderUpdate(_ sender: UISlider) {
        let val = Int(sender.value)
        countdownTimeLabel.text = "\(val)s"
        settings.set(val, forKey: "countdownTime")
    }
}

