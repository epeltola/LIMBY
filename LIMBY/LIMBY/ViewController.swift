//
//  ViewController.swift
//  LIMBY
//
//  Created by Nathan Tsai on 2/1/18.
//  Copyright © 2018 Nathan Tsai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var segmentController: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // day week month year
    @IBAction func timeScale(_ sender: Any) {
        print("something happened in segmentedcontrol")
    }

    @IBAction func disconnectDevice(_ sender: Any) {
        print("Disconnect Device button pressed")
    }

    @IBAction func leftArrow(_ sender: Any) {
        print("left arrow pressed")
    }

    @IBAction func rightArrow(_ sender: Any) {
        print("right arrow pressed")
    }
}

