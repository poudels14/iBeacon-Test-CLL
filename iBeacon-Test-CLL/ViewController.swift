//
//  ViewController.swift
//  iBeacon-Test-CLL
//
//  Created by Sagar Poudel on 3/24/15.
//  Copyright (c) 2015 Sagar Poudel. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
//  iPod UUID = 8492E75F-4FD6-469D-B132-043FE94921D8
    var r2 = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "*"), identifier: "Estimote iOS")
    let beaconFoundSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep-07", ofType: "wav")!)
    let beaconCloseSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep-07-low-tempo", ofType: "wav")!)
    
    var ap = AVAudioPlayer()
    var error:NSError?
    var totalBeacons:Int = 0
    
    var uuidSet: Bool = false
    var isMonitoring:Bool = false
    

    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var seperator: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set all delegates and selector
        locationManager.delegate = self
        textField.delegate = self
        goButton.addTarget(self, action: "setUUID", forControlEvents: UIControlEvents.TouchDown)
        
        locationManager.requestAlwaysAuthorization()
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        //set default text in text box
        textField.text = "8492E75F-4FD6-469D-B132-043FE94921D8"
        
        warningLabel.textAlignment = NSTextAlignment.Center
        
        label.text = "\(totalBeacons) beacons found"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(21)
        
        label.backgroundColor = UIColor(red: 100, green: 120, blue: 100, alpha: 1)
        
        seperator.frame = CGRect(x: seperator.frame.origin.x, y: seperator.frame.origin.y, width: seperator.bounds.size.width, height: 1)
        seperator.backgroundColor = UIColor.blackColor()
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        var soundPlayed: Bool = false
        var playSound:Bool = false
        var isDanger:Bool = false
        
        if (totalBeacons != beacons.count){
            totalBeacons = beacons.count
            label.text = "\(totalBeacons) beacons found"
        }
        
        for b in beacons {
            playSound = true
            println(b.proximity.rawValue)
            println(b.rssi)
            if (b.rssi > -20){
                ap = AVAudioPlayer(contentsOfURL: beaconCloseSound, error: &error)
                ap.play()
                soundPlayed = true
                isDanger = true
            }
        }
        
        if (isDanger){
            self.view.backgroundColor = UIColor.redColor()
        }
        else{
            self.view.backgroundColor = UIColor.whiteColor()
        }
        
        if (!soundPlayed && playSound){
            ap = AVAudioPlayer(contentsOfURL: beaconFoundSound, error: &error)
            ap.play()
        }
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    func setUUID() {
        println("New UUID set: \(textField.text)")
        var r3 = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "\(textField.text)"), identifier: "new Beacon")
        if (isMonitoring){
            locationManager.stopRangingBeaconsInRegion(r2)
            isMonitoring = false
        }
        
        if (r3 == nil){
            r2 = r3
            warningLabel.text = "Invalid UUID"
        }
        else{
            r2 = r3
            warningLabel.text = ""
            locationManager.startRangingBeaconsInRegion(r2)
            isMonitoring = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

