//
//  testTodayViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/07/10.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit

class testTodayViewController: UIViewController {

    @IBOutlet var frame: UIView!
    @IBOutlet var innerView: UIView!
    
    @IBOutlet var selectDayBT: UIButton!
    @IBOutlet var selectDay: UILabel!
    @IBOutlet var selectDayBgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setRadius()
        setShadow(innerView)
        setShadowDayBgView()
//        selectDay.text = "Today"
        selectDay.text = "2021.07.11"
        
    }
    
    @IBAction func saveImage(_ sender: Any) {
        saveImage(frame!)
        showAlert()
    }
}


extension testTodayViewController {
    
    func setRadius() {
        innerView.layer.cornerRadius = 25
        selectDayBgView.layer.cornerRadius = 12
    }
    
    func setShadow(_ view: UIView) {
        view.layer.shadowColor = UIColor(named: "shadow")?.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 5
    }
    
    func setShadowDayBgView() {
        selectDayBgView.layer.masksToBounds = false
//        selectDayBgView.layer.shadowColor = todayViewManager.COLOR.cgColor
        selectDayBgView.layer.shadowColor = UIColor(named: "D1")?.cgColor
        selectDayBgView.layer.shadowOpacity = 0.5
        selectDayBgView.layer.shadowOffset = CGSize.zero
        selectDayBgView.layer.shadowRadius = 5.5
        
//        selectDay.layer.shadowColor = todayViewManager.COLOR.cgColor
        selectDay.layer.shadowColor = UIColor(named: "D1")?.cgColor
        selectDay.layer.shadowOpacity = 1
        selectDay.layer.shadowOffset = CGSize(width: 1, height: 0.5)
        selectDay.layer.shadowRadius = 1.5
    }
    
    func showAlert() {
        let alert = UIAlertController(title:"Save completed".localized(),
            message: "",
            preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func saveImage(_ getFrame: UIView) {
        let img = UIImage.init(view: getFrame)
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
}
