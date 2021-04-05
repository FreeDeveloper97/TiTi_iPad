//
//  taskSelectViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/04/05.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit

class taskSelectViewController: UIViewController {

    var SetTimerViewControllerDelegate : ChangeViewController2!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tasks(_ sender: UIButton) {
        let task = sender.title(for: .normal)!
        UserDefaults.standard.set(task, forKey: "task")
        SetTimerViewControllerDelegate.changeTask()
        self.dismiss(animated: true, completion: nil)
    }
    

}
