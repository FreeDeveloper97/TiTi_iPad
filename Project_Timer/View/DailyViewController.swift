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
    @IBOutlet var sumTime: UILabel!
    @IBOutlet var taskTitle: UILabel!
    @IBOutlet var taskTime: UILabel!
    @IBOutlet var taskPersent: UILabel!
    var printTitle: [String] = []
    var printTime: [String] = []
    var printPersent: [String] = []
    var colors: [UIColor] = []
    var counts: Int = 0
    var fixed_sum: Int = 0
    let f = Float(0.003)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var temp: [String:Int] = [:]
        
//        var daily = Daily()
//        daily.load()
//        print(daily.tasks)
//        temp = daily.tasks
//        temp["breakTime"] = daily.breakTime
        temp = addDumy()
        
        
        counts = temp.count
        appendColors()
        
        let tasks = temp.sorted(by: { $0.1 < $1.1 } )
        
        var array: [Int] = []
        for (key, value) in tasks {
            printTitle.append(key)
            printTime.append(printTime(temp: value))
            array.append(value)
        }
        
        let width = progress.bounds.width
        let height = progress.bounds.height
        makeProgress(array, width, height)
        var p1 = ""
        var p2 = ""
        var p3 = ""
        for i in (0..<tasks.count).reversed() {
            p1 += "\(printTitle[i])\n"
            p2 += "\(printTime[i])\n"
            p3 += "\(printPersent[i])\n"
        }
        taskTitle.text = p1
        taskTime.text = p2
        taskPersent.text = p3
    }
}


extension DailyViewController {
    
    func appendColors() {
        //case 1
//        //19 37 70
//        var R: CGFloat = 1
//        var G: CGFloat = 8
//        var B: CGFloat = 40
//        let perR = (255-R)/CGFloat(counts)
//        let perG = (255-G)/CGFloat(counts)
//        let perB = (255-B)/CGFloat(counts)
//        R = 255
//        G = 255
//        B = 255
//
//        for _ in 0..<counts {
//            colors.append(UIColor(R, G, B, 1.0))
//            R -= perR
//            G -= perG
//            B -= perB
//        }
        //case 2
        for i in 1...12 {
            colors.append(UIColor(named: "CC\(i)")!)
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
        fixed_sum = 0
        for i in 0..<counts {
            fixed_sum += datas[i]
        }
        var sum = Float(fixed_sum)
        sumTime.text = printTime(temp: fixed_sum)
        //그래프 간 구별선 추가
        sum += f*Float(counts)
        
        var value: Float = 1
        value = addBlock(value: value, width: width, height: height)
        for i in 0..<counts {
            let prog = CircularProgressView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            prog.trackColor = UIColor.clear
            prog.progressColor = colors[i%colors.count]
            print(value)
            prog.setProgressWithAnimation(duration: 1, value: value, from: 0)
            
            let per = Float(datas[i])/Float(sum) //그래프 퍼센트
            let fixed_per = Float(datas[i])/Float(fixed_sum)
            value -= per
            
            progress.addSubview(prog)
            printPersent.append(String(format: "%.1f", fixed_per*100) + "%")
            
            value = addBlock(value: value, width: width, height: height)
        }
        
    }
    
    func addGraph() {
        
    }
    
    func addBlock(value: Float, width: CGFloat, height: CGFloat) -> Float {
        var value = value
        let block = CircularProgressView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        block.trackColor = UIColor.clear
        block.progressColor = UIColor.black
        block.setProgressWithAnimation(duration: 1, value: value, from: 0)
        
        value -= f
        progress.addSubview(block)
        return value
    }
    
    func addDumy() -> [String:Int] {
        var temp: [String:Int] = [:]
//        temp["ios 프로그래밍"] = 2100
//        temp["OS 공부"] = 4680
//        temp["DB 공부"] = 3900
//        temp["통계학 공부"] = 2700
//        temp["영어 공부"] = 2280
//        temp["swift 프로그래밍"] = 2400
//        temp["수업"] = 2160
//        temp["시스템 분석 공부"] = 1800
//        temp["문학세계 공부"] = 1200
        temp["코딩테스트 공부"] = 2200
        temp["자바스크립트 공부"] = 1980
        temp["휴식 시간"] = 2500
        
        return temp
    }
}
