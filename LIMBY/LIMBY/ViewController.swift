//
//  ViewController.swift
//  LIMBY
//
//  Created by Nathan Tsai on 2/1/18.
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

var queue : [String] = []

class ViewController: UIViewController {
    enum ParticleError: Error{
        case loginError
        case logicError
    }
    func login(username : String, password : String) -> Bool {
        var success : Bool = true
        ParticleCloud.sharedInstance().login(withUser: username, password: password) { (error:Error?) -> Void in
            if let _ = error {
                eprint(message: "Wrong credentials or no internet connectivity, please try again")
                success = false
            }
            else {
                eprint(message: "Logged in")
            }
        }
        return success
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
                eprint (message: "could not subscribe to events")
            } else {
                let serialQueue = DispatchQueue(label: "getWeight")
                serialQueue.sync(execute: {
                    if let event = eventOpt{
                        if let eventData = event.data {
                            eprint(message: "got event with data \(eventData)")
                            queue.append(eventData)
                        }
                    }
                    else{
                        eprint(message: "Event is nil")
                    }
                })
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let status : Bool = login(username: "peifeng2005@gmail.com", password: "peifeng2005")
        
        if status {
            subscribe(prefix: "weight")
        }
        else {
            eprint(message: "Unable to log in. Exiting.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

