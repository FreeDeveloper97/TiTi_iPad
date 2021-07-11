//
//  TodayViewManager.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/06/17.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit

class TodayViewManager {
    var arrayTaskName: [String] = []
    var arrayTaskTime: [String] = []
    var colors: [UIColor] = []
    var fixed_sum: Int = 0
    let f = Float(0.003)
    var daily = Daily()
    var counts: Int = 0
    var array: [Int] = []
    var fixedSum: Int = 0
    var startColor: Int = 1
    var reverseColor: Bool = false
    
    var COLOR: UIColor = UIColor(named: "D1")!
    
    func saveImage(_ frame: UIView) {
        let width: Double = Double(frame.bounds.width)
        let height: Double = Double(frame.bounds.height)
        let img = UIImage.init(view: frame)
        if(height > width) {
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        } else {
            let rectImg = cropToBounds(image: img, width: width, height: height)
            UIImageWriteToSavedPhotosAlbum(rectImg, nil, nil, nil)
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func setStartColorIndex(_ i: Int) {
        if(i == startColor) {
            reverseColor = !reverseColor
        } else { reverseColor = false }
        startColor = i
        UserDefaults.standard.setValue(startColor, forKey: "startColor")
    }
    
    func reset() {
        arrayTaskName = []
        arrayTaskTime = []
        colors = []
        fixed_sum = 0
        daily = Daily()
        counts = 0
        array = []
        fixedSum = 0
        startColor = 1
    }
    
    func appendColors() {
        COLOR = UIColor(named: "D\(startColor)")!
        if(!reverseColor) {
            var i = (counts+(startColor-1))%12
            if(i == 0) {
                i = 12
            }
            print(i)
            for _ in 1...counts {
                colors.append(UIColor(named: "D\(i)")!)
                i -= 1
                if(i == 0) {
                    i = 12
                }
            }
        }
        else {
            print("reverse")
            var i = ((startColor-counts+1)+12)%12
            if(i == 0) {
                i = 12
            }
            print(i)
            for _ in 1...counts {
                colors.append(UIColor(named: "D\(i)")!)
                i += 1
                if(i == 13) {
                    i = 1
                }
            }
        }
    }
    
    func setDay(_ today: UILabel) {
        let stringDay = getDay(day: daily.day)
        today.text = stringDay
    }
    
    func getDay(day: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd"
        return dateFormatter.string(from: day)
    }
    
    func setWeek(_ weeks: [UIView]) {
        let todayNum = weekday(daily.day)
        for i in 0..<7 {
            if(i == todayNum) {
                let target: UIView = weeks[todayNum]
                target.backgroundColor = COLOR
            } else {
                let target: UIView = weeks[i]
                target.backgroundColor = UIColor.clear
            }
        }
    }
    
    func weekday(_ today: Date) -> Int {
        let _ = Calendar(identifier: .gregorian)
        let day = Calendar.current.component(.weekday, from: today) - 1
        print("day : \(day)")
        return day
    }
    
    func setTasksColor() {
        counts = daily.tasks.count
        appendColors()
    }
    
    func getTasks() {
        let temp: [String:Int] = daily.tasks
//            let temp = addDumy()
        
        let tasks = temp.sorted(by: { $0.1 < $1.1 } )
        for (key, value) in tasks {
            let value = value
            arrayTaskName.append(key)
            arrayTaskTime.append(ViewManager().printTime(value))
            array.append(value)
        }
    }
    
    func makeProgress(_ view: UIView) {
        let datas = array
        let width = view.bounds.width
        let height = view.bounds.height
        
        print(datas)
        for i in 0..<counts {
            fixedSum += datas[i]
        }
        var sum = Float(fixedSum)
        
        //그래프 간 구별선 추가
        sum += f*Float(counts)
        
        var value: Float = 1
        value = addBlock(value: value, view: view)
        for i in 0..<counts {
            let prog = StaticCircularProgressView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            prog.progressWidth = 50
            prog.trackColor = UIColor.clear
            prog.progressColor = colors[i%colors.count]
            print(value)
            prog.setProgressWithAnimation(duration: 0.7, value: value, from: 0)
            
            let per = Float(datas[i])/Float(sum) //그래프 퍼센트
            value -= per
            
            view.addSubview(prog)
            
            value = addBlock(value: value, view: view)
        }
        
    }
    
    func addBlock(value: Float, view: UIView) -> Float {
        let width = view.bounds.width
        let height = view.bounds.width
        var value = value
        let block = StaticCircularProgressView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        block.trackColor = UIColor.clear
        block.progressColor = UIColor.systemBackground
        block.progressWidth = 50
        block.setProgressWithAnimation(duration: 0.7, value: value, from: 0)
        
        value -= f
        view.addSubview(block)
        return value
    }
    
    func showTimes(_ sum1: UILabel, _ max1: UILabel) {
        let stringSum = ViewManager().printTime(fixedSum)
        sum1.text = stringSum
        sum1.textColor = COLOR
        
        let stringMax = ViewManager().printTime(daily.maxTime)
        max1.text = stringMax
        max1.textColor = COLOR
    }
    
    func setDumyDaily() {
        daily = Dumy().getDumyDaily()
    }
    
    func getColor() {
        startColor = UserDefaults.standard.value(forKey: "startColor") as? Int ?? 1
        COLOR = UIColor(named: "D\(startColor)")!
    }
    
    func setTimesColor(_ sum1: UILabel, _ max1: UILabel) {
        COLOR = UIColor(named: "D\(startColor)")!
        sum1.textColor = COLOR
        max1.textColor = COLOR
    }
}
