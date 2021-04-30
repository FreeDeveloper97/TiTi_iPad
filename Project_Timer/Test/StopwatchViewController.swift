//
//  StopwatchViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/04/30.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit

class StopwatchViewController: UIViewController {

    @IBOutlet var taskButton: UIButton!
    @IBOutlet var taskLine: UIView!
    @IBOutlet var innerProgress: CircularProgressView!
    @IBOutlet var outterProgress: CircularProgressView!
    
    @IBOutlet var TIMEofSum: UILabel!
    @IBOutlet var TIMEofCenter: UILabel!
    @IBOutlet var TIMEofRest: UILabel!
    
    @IBOutlet var modeStopWatch: UIButton!
    @IBOutlet var modeTimer: UIButton!
    @IBOutlet var log: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func taskBTAction(_ sender: Any) {
    }
    
    @IBAction func timerBTAction(_ sender: Any) {
    }
    
    @IBAction func showLog(_ sender: Any) {
    }
    
}
