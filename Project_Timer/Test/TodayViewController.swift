//
//  TodayViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/05/13.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit
import SwiftUI

class TodayViewController: UIViewController {

    
    @IBOutlet var mon: UIView!
    @IBOutlet var tue: UIView!
    @IBOutlet var wed: UIView!
    @IBOutlet var thu: UIView!
    @IBOutlet var fri: UIView!
    @IBOutlet var set: UIView!
    @IBOutlet var sun: UIView!
    
    @IBOutlet var today: UILabel!
    @IBOutlet var sumTime: UILabel!
    @IBOutlet var maxTime: UILabel!
    @IBOutlet var progress: UIView!
    
    @IBOutlet var timeline: UIView!
    
    @IBOutlet var sumLabel1: UILabel!
    @IBOutlet var sumLabel2: UILabel!
    @IBOutlet var sumHeight: NSLayoutConstraint!
    @IBOutlet var maxLabel1: UILabel!
    @IBOutlet var maxLabel2: UILabel!
    @IBOutlet var maxHeight: NSLayoutConstraint!
    @IBOutlet var ratioLabel1: UILabel!
    @IBOutlet var ratioLabel2: UILabel!
    @IBOutlet var ratioHeight: NSLayoutConstraint!
    
    
    var arrayTaskName: [String] = []
    var arrayTaskTime: [String] = []
    var colors: [UIColor] = []
    var fixed_sum: Int = 0
    let f = Float(0.003)
    var daily = Daily()
    var counts: Int = 0
    var array: [Int] = []
    var fixedSum: Int = 0
    
    var COLOR: UIColor = UIColor(named: "CCC1")!
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        //timeline
        let hostingController = UIHostingController(rootView: todayContentView())
        hostingController.view.translatesAutoresizingMaskIntoConstraints = true
        hostingController.view.frame = timeline.bounds
        todayContentView().appendTimes()
//        ContentView().appendDumyDatas()
        addChild(hostingController)
        timeline.addSubview(hostingController.view)
        
        
        //extra
        daily.load()
        if(daily.tasks != [:]) {
            setDay()
            getTasks()
            setProgress()
            setTimes()
        } else {
            print("no data")
        }
        checkRotate()
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("disappear in today")
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func deviceRotated(){
        afterRotate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        todayContentView().reset()
    }

    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension TodayViewController {
    
    func checkRotate() {
        let del = UIApplication.shared.delegate as! AppDelegate
        if del.isLandscape == false {
            //Code here
            print("Portrait")
            setPortrait()
        } else if del.isLandscape == true {
            //Code here
            print("Landscape")
            setLandscape()
        } else { }
    }
    
    func afterRotate() {
        if UIDevice.current.orientation.isPortrait {
            //Code here
            print("Portrait")
            setPortrait()
        } else if UIDevice.current.orientation.isLandscape {
            //Code here
            print("Landscape")
            setLandscape()
        } else { }
    }
    
    func setPortrait() {
        sumLabel1.alpha = 1
        sumLabel2.alpha = 1
        maxLabel1.alpha = 1
        maxLabel2.alpha = 1
        ratioLabel1.alpha = 1
        ratioLabel2.alpha = 1
        
        sumHeight.constant = 55
        maxHeight.constant = 55
        ratioHeight.constant = 74.5
        view.layoutIfNeeded()
    }
    
    func setLandscape() {
        sumLabel1.alpha = 0
        sumLabel2.alpha = 0
        maxLabel1.alpha = 0
        maxLabel2.alpha = 0
        ratioLabel1.alpha = 0
        ratioLabel2.alpha = 0
        
        sumHeight.constant = 5
        maxHeight.constant = 5
        ratioHeight.constant = 25
        view.layoutIfNeeded()
    }
    
    func getDay(day: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd"
        return dateFormatter.string(from: day)
    }
    
    func appendColors() {
        var i = counts%12
        if(i == 0) {
            i = 12
        }
        for _ in 1...counts {
            colors.append(UIColor(named: "CCC\(i)")!)
            i -= 1
            if(i == 0) {
                i = 12
            }
        }
    }
    
    func printTime(temp : Int) -> String
    {
        let S = temp%60
        let H = temp/3600
        let M = temp/60 - H*60
        
        let stringS = S<10 ? "0"+String(S) : String(S)
        let stringM = M<10 ? "0"+String(M) : String(M)
        
        let returnString  = String(H) + ":" + stringM + ":" + stringS
        return returnString
    }
    
    func makeProgress(_ datas: [Int], _ width: CGFloat, _ height: CGFloat) {
        print(datas)
        for i in 0..<counts {
            fixedSum += datas[i]
        }
        var sum = Float(fixedSum)
        sumTime.text = printTime(temp: fixedSum)
        
        //그래프 간 구별선 추가
        sum += f*Float(counts)
        
        var value: Float = 1
        value = addBlock(value: value, width: width, height: height)
        for i in 0..<counts {
            let prog = StaticCircularProgressView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            prog.progressWidth = 40.0
            prog.trackColor = UIColor.clear
            prog.progressColor = colors[i%colors.count]
            print(value)
            prog.setProgressWithAnimation(duration: 1, value: value, from: 0)
            
            let per = Float(datas[i])/Float(sum) //그래프 퍼센트
            value -= per
            
            progress.addSubview(prog)
            
            value = addBlock(value: value, width: width, height: height)
        }
        
    }
    
    func addBlock(value: Float, width: CGFloat, height: CGFloat) -> Float {
        var value = value
        let block = StaticCircularProgressView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        block.progressWidth = 40.0
        block.trackColor = UIColor.clear
        block.progressColor = UIColor.black
        block.setProgressWithAnimation(duration: 1, value: value, from: 0)
        
        value -= f
        progress.addSubview(block)
        return value
    }
    
    func weekday(_ today: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let day = Calendar.current.component(.weekday, from: today) - 1
        print("day : \(day)")
        return day
    }
    
    func setWeek() {
        let todayNum = weekday(daily.day)
        switch(todayNum) {
        case 1:
            mon.backgroundColor = COLOR
        case 2:
            tue.backgroundColor = COLOR
        case 3:
            wed.backgroundColor = COLOR
        case 4:
            thu.backgroundColor = COLOR
        case 5:
            fri.backgroundColor = COLOR
        case 6:
            set.backgroundColor = COLOR
        case 7:
            sun.backgroundColor = COLOR
        default:
            mon.backgroundColor = UIColor.clear
        }
    }
    
    func setDay() {
        today.text = getDay(day: daily.day)
        setWeek()
    }
    
    func getTasks() {
        let temp: [String:Int] = daily.tasks
//            let temp = addDumy()
        counts = temp.count
        
        let tasks = temp.sorted(by: { $0.1 < $1.1 } )
        for (key, value) in tasks {
            arrayTaskName.append(key)
            arrayTaskTime.append(printTime(temp: value))
            array.append(value)
        }
    }
    
    func setProgress() {
        appendColors()
        let width = progress.bounds.width
        let height = progress.bounds.height
        makeProgress(array, width, height)
    }
    
    func setTimes() {
        sumTime.text = printTime(temp: fixedSum)
        sumTime.textColor = COLOR
        maxTime.text = printTime(temp: daily.maxTime)
        maxTime.textColor = COLOR
    }
}

extension TodayViewController: UICollectionViewDataSource {
    //몇개 표시 할까?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return counts
    }
    //셀 어떻게 표시 할까?
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath) as? todayCell else {
            return UICollectionViewCell()
        }
        let color = colors[counts - indexPath.item - 1]
        cell.check.textColor = color
        cell.taskName.text = arrayTaskName[counts - indexPath.item - 1]
        cell.taskTime.text = arrayTaskTime[counts - indexPath.item - 1]
        cell.taskTime.textColor = color
        
        return cell
    }
}

extension TodayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO: 사이즈 계산하기 : OK
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 45
        return CGSize(width: width, height: height)
    }
}

class todayCell: UICollectionViewCell {
    @IBOutlet var check: UILabel!
    @IBOutlet var taskName: UILabel!
    @IBOutlet var taskTime: UILabel!
}
