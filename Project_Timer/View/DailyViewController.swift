//
//  GraphViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/04/06.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit
import Foundation

class DailyViewController: UIViewController {

    @IBOutlet var progress: UIView!
    @IBOutlet var taskTitle: UILabel!
    @IBOutlet var taskTime: UILabel!
    @IBOutlet var taskPersent: UILabel!
    var printTitle: String = ""
    var printTime: String = ""
    var printPersent: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var daily = Daily()
        daily.load()
        print(daily.tasks)
        
        let width = progress.bounds.width
        let height = progress.bounds.height
        var tasks = daily.tasks
        tasks["breakTime"] = daily.breakTime
        
        var array: [Int] = []
        for (key, value) in tasks {
            printTitle += "\(key)\n"
            printTime += "\(printTime(temp: value))\n"
            array.append(value)
        }
        
        makeProgress(array, width, height)
        
        taskTitle.text = printTitle
        taskTime.text = printTime
        taskPersent.text = printPersent
    }
    

    

}


extension DailyViewController {
    
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
        var sum = 0
        for i in 0..<datas.count {
            sum += datas[i]
        }
        var value: Float = 1
        for i in 0..<datas.count {
            let prog = CircularProgressView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            prog.trackColor = UIColor.clear
            if(i%3 == 0) {
                prog.progressColor = UIColor.orange
            } else if(i%3 == 1) {
                prog.progressColor = UIColor.red
            } else {
                prog.progressColor = UIColor.yellow
            }
            print(value)
            prog.setProgressWithAnimation(duration: 1, value: value, from: 0)
            let per = Float(datas[i])/Float(sum)
            value -= per
            progress.addSubview(prog)
            printPersent += "\(String(format: "%.1f", per*100))" + "%\n"
        }
        
    }
}
