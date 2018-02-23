//
//  ViewController.swift
//  LIMBY
//
//  Created by Na Tai on 2/1/18.
//  Copyright © 2018 Nathan Tsai. All rights reserved.
//

import UIKit

var standardError = FileHandle.standardError

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

func eprint(message : String) {
    print(message, to: &standardError)
}

/**
 A Singleton class for data queue feeds. Requires a login onto the particle device and the queue
 will be asynchronously filled with data.
 */
class DataQueue {
    static let singleton = DataQueue()
    var queue : [String] = []
    private init(){ /* Singletons should be private ctor'd */ }
    
    enum ParticleError: Error{
        case loginError
        case logicError
    }
    
    func login(username : String, password : String, vc : ViewController) {
        ParticleCloud.sharedInstance().login(withUser: username, password: password) { (error:Error?) -> Void in
            if let _ = error {
                let alert = UIAlertController(title: "Error", message:
                    "Wrong credentials or no internet connectivity. Please" +
                    " try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss",
                    style: UIAlertActionStyle.default, handler: nil))
                vc.present(alert, animated: true, completion: nil)
                self.handleErrorAuth(vc: vc)
            }
            else {
                eprint(message: "Logged in")
                self.segueToMainAuth(vc: vc)
            }
        }
    }
    
    func segueToMainAuth(vc : ViewController) -> Void {
        let graphViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "lineChartViewController") as! LineChartViewController
        vc.navigationController?.pushViewController(graphViewController, animated: true)
    }
    
    func handleErrorAuth(vc : ViewController) -> Void{
        eprint(message: "Error!")
    }
    
    func checkExist(deviceName : String) -> Bool {
        var exists : Bool = true
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                eprint(message: "Check your internet connectivity")
                exists = false
            }
            else {
                if let d = devices {
                    for device in d {
                        if device.name == deviceName {
                            eprint(message: "Successfully retrieved chicken weigher.")
                        }
                        else {
                            exists = false
                        }
                    }
                }
            }
        }
        return exists
    }
    
    func subscribe(prefix : String){
        ParticleCloud.sharedInstance().subscribeToAllEvents(withPrefix: prefix, handler: { (eventOpt :ParticleEvent?, error : Error?) in
            if let _ = error {
                eprint (message: "Could not subscribe to events")
            } else {
                let serialQueue = DispatchQueue(label: "getWeight")
                serialQueue.async(execute: {
                    if let event = eventOpt{
                        if let eventData = event.data {
                            eprint(message: "got event with data \(eventData)")
                            let components = eventData.components(separatedBy: "\t")
                            if components.count == 2 {
                                self.queue.append(eventData)
                            }
                        }
                    }
                    else{
                        eprint(message: "Event is nil")
                    }
                })
            }
        })
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var ProjectName: UILabel!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ConnectDevice(_ sender: UIButton) {
        //authenticate input and go to main screen
        DataQueue.singleton.login(username: Username.text!, password: Password.text!, vc: self)
    }
    

    
    
}



