//
//  CrashEvent.swift
//  RubberSideDown
//
//  Created by Graham Nelson on 11/8/19.
//  Copyright © 2019 Graham Nelson. All rights reserved.
//

import Foundation
import Alamofire

var countdownTime = 30
var timer: Timer?
var emergencyMessage = ""
var okMessage = ""
var userLocation = ""

let settings = UserDefaults.standard

var SID = ""
var TOKEN = ""

class CrashEvent {
    
    init(){
        setTokens()
    }
    
    func startTimer(){
        setCountdownTime()
        setEmergencyMessage()
        setOKMessage()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {timer in
            if countdownTime == 0 {
                self.stopTimer()
            }
            countdownTime = countdownTime - 1
        })
    }
    
    func setCountdownTime(){
        let count = settings.integer(forKey: "countdownTime")
        if count >= 10 && count <= 60 {
            countdownTime = count
        }
    }
    
    func setUserLocation(location: String){
        userLocation = location
    }
    
    func getCountdownTime() -> Int{
        return countdownTime
    }
    
    func stopTimer(){
        timer?.invalidate()
        setCountdownTime()
    }
    
    func setTokens(){
        guard let path = Bundle.main.path(forResource: "TWILIO_INFO", ofType: "txt") else {return}
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                if let sid = json["TWILIO_SID"] {
                    SID = sid
                }
                if let token = json["TWILIO_AUTH_TOKEN"] {
                    TOKEN = token
                }
            }
        } catch {
            print("TWILIO_INFO.txt is missing or contains incorrect values")
        }
    }
    
    func setEmergencyMessage(){
        var riderName = settings.string(forKey: "riderName")
        if riderName == ""{
            riderName = "Rider"
        }
        let bikeMake = settings.string(forKey: "bikeMake")
        let bikeModel = settings.string(forKey: "bikeModel")
        let bikeColor = settings.string(forKey: "bikeColor")
        
        if (bikeMake == "" && bikeModel == ""){
            emergencyMessage = "Rubber Side Down: \(riderName ?? "Rider")'s bike is down near: \(userLocation)"
        } else {
            emergencyMessage = "Rubber Side Down: \(riderName ?? "Rider")'s \(bikeColor ?? "") \(bikeMake ?? "") \(bikeModel ?? "bike") is down near: \(userLocation)"
        }
    }
    
    func setOKMessage(){
        let riderName = settings.string(forKey: "riderName")!
        if riderName == "" {
            okMessage = "Rider has responded to Rubber Side Down, rider is OK!"
        } else {
            okMessage = "\(riderName) has responded to Rubber Side Down, \(riderName) is OK!"
        }
    }
    
    func sendEmergencyMessage(){
        sendSMS(emergencyMessage, to: settings.string(forKey: "contact0Number") ?? "")
        sendSMS(emergencyMessage, to: settings.string(forKey: "contact1Number") ?? "")
        sendSMS(emergencyMessage, to: settings.string(forKey: "contact2Number") ?? "")
    }
    
    func sendOKMessage(){
        sendSMS(okMessage, to: settings.string(forKey: "contact0Number") ?? "")
        sendSMS(okMessage, to: settings.string(forKey: "contact1Number") ?? "")
        sendSMS(okMessage, to: settings.string(forKey: "contact2Number") ?? "")
    }
    
    //send request to twilio api to send SMS
    func sendSMS(_ message: String, to recipient: String){
        if recipient != ""{
            let url = "https://api.twilio.com/2010-04-01/Accounts/\(SID)/Messages"
            let param = ["From": "5102503891", "To": recipient, "Body": message]
            AF.request(url, method: .post, parameters: param)
                .authenticate(username: SID, password: TOKEN)
                .response{ response in }
            //print("Message sent to \(recipient): \(message)")
        }
    }
}
