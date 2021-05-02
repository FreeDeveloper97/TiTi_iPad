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
    @IBOutlet var taskLeft: UILabel!
    @IBOutlet var taskRight: UILabel!
    @IBOutlet var innerProgress: CircularProgressView!
    @IBOutlet var outterProgress: CircularProgressView!
    
    @IBOutlet var sumTimeLabel: UILabel!
    @IBOutlet var TIMEofSum: UILabel!
    @IBOutlet var stopWatchLabel: UILabel!
    @IBOutlet var TIMEofStopwatch: UILabel!
    @IBOutlet var targetTimeLabel: UILabel!
    @IBOutlet var TIMEofTarget: UILabel!
    @IBOutlet var finishTimeLabel: UILabel!
    
    @IBOutlet var modeStopWatch: UIButton!
    @IBOutlet var modeTimer: UIButton!
    @IBOutlet var log: UIButton!
    @IBOutlet var lineLeft: UIView!
    @IBOutlet var lineRight: UIView!
    
    @IBOutlet var startStopBT: UIButton!
    @IBOutlet var tempBT: UIButton!
    @IBOutlet var settingBT: UIButton!
    
    var COLOR = UIColor(named: "Background2")
    let BUTTON = UIColor(named: "Button")
    let CLICK = UIColor(named: "Click")
    let RED = UIColor(named: "Text")
    
    var timeTrigger = true
    var realTime = Timer()
    var sumTime : Int = 0
    var sumTime2 : Int = 0
    var goalTime : Int = 0
    var breakTime : Int = 0
    var breakTime2 : Int = 0
    var diffHrs = 0
    var diffMins = 0
    var diffSecs = 0
    var isStop = true
    var isBreak = false
    var isFirst = false
    var progressPer: Float = 0.0
    var fixedSecond: Int = 3600
    var fixedBreak: Int = 300
    var beforePer: Float = 0.0
    var showAvarage: Int = 0
    var array_day = [String](repeating: "", count: 7)
    var array_time = [String](repeating: "", count: 7)
    var array_break = [String](repeating: "", count: 7)
    var stopCount: Int = 0
    var VCNum: Int = 2
    var totalTime: Int = 0
    var beforePer2: Float = 0.0
    var task: String = ""
    //하루 그래프를 위한 구조
    var daily = Daily()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modeStopWatch.setTitleColor(UIColor.darkGray, for: .normal)
        modeStopWatch.isUserInteractionEnabled = false
        tempBT.alpha = 0
        setVCNum()
        setLocalizable()
        
        setButtonRotation()
        setColor()
        setRadius()
        setShadow()
        setBorder()
        setDatas()
        setTimes()
        
        stopColor()
        stopEnable()
        allStopColor()
        
        setBackground()
        checkIsFirst()
        checkAverage()
        
        setFirstProgress()
        
        daily.load()
        setTask()
    }
    
    func checkTimeTrigger() {
        realTime = Timer.scheduledTimer(timeInterval: 1, target: self,
            selector: #selector(updateCounter), userInfo: nil, repeats: true)
        timeTrigger = false
    }
    
    func breakTimeTrigger() {
        realTime = Timer.scheduledTimer(timeInterval: 1, target: self,
            selector: #selector(updateBreaker), userInfo: nil, repeats: true)
        timeTrigger = false
    }
    
    @objc func updateCounter(){
        sumTime += 1
        goalTime -= 1
        sumTime2 = sumTime%fixedSecond
        
        updateTimeLabels()
        updateProgress()
        printLogs()
        saveTimes()
        showNowTime()
//        //하루 그래프 데이터 계산
//        daily.stopTask()
//        daily.save()
    }
    
    @objc func updateBreaker() {
        breakTime += 1
        breakTime2 = breakTime%fixedBreak
        
        updateBreakTimeLabels()
        updateBreakProgress()
        saveBreak()
        finishTimeLabel.text = getFutureTime()
        //하루 그래프 휴식시간 저장
        daily.breakTime = breakTime
    }
    
    @IBAction func taskBTAction(_ sender: Any) {
        showTaskView()
    }
    
    @IBAction func timerBTAction(_ sender: Any) {
        algoOfBreakStop()
        UserDefaults.standard.set(1, forKey: "VCNum")
        goToViewController(where: "TimerViewController")
    }
    
    @IBAction func startStopBTAction(_ sender: Any) {
        //start action
        if(isStop == true) {
            algoOfBreakStop()
            algoOfStart()
        }
        //stop action
        else {
            algoOfStop()
            algoOfBreakStart()
        }
    }
    
    @IBAction func settingBTAction(_ sender: Any) {
        showSettingView()
    }
}

extension StopwatchViewController : ChangeViewController2 {
    
    func changeGoalTime() {
        algoOfBreakStop()
        
        isFirst = true
        UserDefaults.standard.set(nil, forKey: "startTime")
        setColor()
        goalTime = UserDefaults.standard.value(forKey: "allTime") as? Int ?? 0
        showAvarage = UserDefaults.standard.value(forKey: "showPersent") as? Int ?? 0
        sumTime = 0
        sumTime2 = 0
        breakTime = 0
        breakTime2 = 0
        
        UserDefaults.standard.set(goalTime, forKey: "allTime2")
        UserDefaults.standard.set(sumTime, forKey: "sum2")
        UserDefaults.standard.set(breakTime, forKey: "breakTime")
        
        resetStopCount()
        resetProgress()
        updateTimeLabels()
        finishTimeLabel.text = getFutureTime()
        
        stopColor()
        stopEnable()
        checkAverage()
        allStopColor()
        //하루 그래프 초기화
        daily.reset()
    }
    
    func changeTask() {
        setTask()
    }
}


extension StopwatchViewController {
    
    func setBackground() {
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func pauseWhenBackground(noti: Notification) {
        print("background")
        if(!isStop) {
            realTime.invalidate()
            timeTrigger = true
            let shared = UserDefaults.standard
            shared.set(Date(), forKey: "savedTime")
        } else if(isBreak) {
            realTime.invalidate()
            timeTrigger = true
            let shared = UserDefaults.standard
            shared.set(Date(), forKey: "savedTime")
        }
    }
    
    @objc func willEnterForeground(noti: Notification) {
        print("Enter")
        finishTimeLabel.text = getFutureTime()
        if(!isStop) {
            if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date {
                (diffHrs, diffMins, diffSecs) = ViewController.getTimeDifference(startDate: savedDate)
                refresh(hours: diffHrs, mins: diffMins, secs: diffSecs)
                removeSavedDate()
            }
        } else if(isBreak) {
            if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date {
                (diffHrs, diffMins, diffSecs) = ViewController.getTimeDifference(startDate: savedDate)
                refreshBreak(hours: diffHrs, mins: diffMins, secs: diffSecs)
                removeSavedDate()
            }
        }
    }
    
    static func getTimeDifference(startDate: Date) -> (Int, Int, Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
        return(components.hour!, components.minute!, components.second!)
    }
    
    func refresh (hours: Int, mins: Int, secs: Int) {
        let tempSeconds = hours*3600 + mins*60 + secs
        
        goalTime = goalTime - tempSeconds
        sumTime = sumTime + tempSeconds
        sumTime2 = sumTime
        sumTime2 %= fixedSecond
        
        updateProgress()
        updateTimeLabels()
        startAction()
        finishTimeLabel.text = getFutureTime()
    }
    
    func refreshBreak (hours: Int, mins: Int, secs: Int) {
        let tempSeconds = hours*3600 + mins*60 + secs
        
        breakTime += tempSeconds
        breakTime2 = breakTime%fixedBreak
        
        updateBreakProgress()
        updateBreakTimeLabels()
        breakStartAction()
        finishTimeLabel.text = getFutureTime()
    }
    
    func removeSavedDate() {
        if (UserDefaults.standard.object(forKey: "savedTime") as? Date) != nil {
            UserDefaults.standard.removeObject(forKey: "savedTime")
        }
    }
    
    func setButtonRotation() {
        startStopBT.transform = CGAffineTransform(rotationAngle: .pi*5/6)
        settingBT.transform = CGAffineTransform(rotationAngle: .pi*1/6)
    }
    
    func setRadius() {
        startStopBT.layer.cornerRadius = 15
        tempBT.layer.cornerRadius = 15
        settingBT.layer.cornerRadius = 15
    }
    
    func setShadow() {
        startStopBT.layer.shadowColor = UIColor.gray.cgColor
        startStopBT.layer.shadowOpacity = 1.0
        startStopBT.layer.shadowOffset = CGSize.zero
        startStopBT.layer.shadowRadius = 6
        settingBT.layer.shadowColor = UIColor.gray.cgColor
        settingBT.layer.shadowOpacity = 1.0
        settingBT.layer.shadowOffset = CGSize.zero
        settingBT.layer.shadowRadius = 6
    }
    
    func setBorder() {
        startStopBT.layer.borderWidth = 5
        startStopBT.layer.borderColor = RED?.cgColor
    }
    
    func setDatas() {
        goalTime = UserDefaults.standard.value(forKey: "allTime2") as? Int ?? 21600
        sumTime = UserDefaults.standard.value(forKey: "sum2") as? Int ?? 0
        showAvarage = UserDefaults.standard.value(forKey: "showPersent") as? Int ?? 0
        stopCount = UserDefaults.standard.value(forKey: "stopCount") as? Int ?? 0
        breakTime = UserDefaults.standard.value(forKey: "breakTime") as? Int ?? 0
        totalTime = UserDefaults.standard.value(forKey: "allTime") as? Int ?? 21600
        
        fixedSecond = 3600
        fixedBreak = 300
        sumTime2 = sumTime%fixedSecond
        breakTime2 = breakTime%fixedBreak
    }
    
    func setTimes() {
        TIMEofSum.text = printTime(temp: sumTime)
        TIMEofStopwatch.text = printTime(temp: sumTime)
        TIMEofTarget.text = printTime(temp: goalTime)
        finishTimeLabel.text = getFutureTime()
    }
    
    func checkIsFirst() {
        if (UserDefaults.standard.object(forKey: "startTime") == nil) {
            isFirst = true
        }
    }
    //평균내용 설정
    func setAverage() {
//        avarageLabel.font = UIFont(name: "HGGGothicssiP60g", size: 23)
//        if(stopCount == 0) {
//            avarageLabel.text = "STOP : " + String(stopCount) + "\nAVER : 0:00:00"
//        } else {
//            var print = "STOP : " + String(stopCount)
//            let aver = (Int)(sumTime/stopCount)
//            print += "\nAVER : " + printTime(temp: aver)
//            avarageLabel.text = print
//        }
    }
    //정지회수 증가 및 저장
    func saveStopCount() {
//        stopCount+=1
//        UserDefaults.standard.set(stopCount, forKey: "stopCount")
    }
    //정지회수 초기화
    func resetStopCount() {
//        stopCount = 0
//        UserDefaults.standard.set(0, forKey: "stopCount")
//        avarageLabel.text = "STOP : " + String(stopCount) + "\nAVER : 0:00:00"
    }
    
    func resetProgress() {
        outterProgress.setProgressWithAnimation(duration: 1.0, value: 0.0, from: beforePer)
        beforePer = 0.0
        //circle2
        totalTime = UserDefaults.standard.value(forKey: "allTime") as? Int ?? 21600
        innerProgress.setProgressWithAnimation(duration: 1.0, value: 0.0, from: beforePer2)
        beforePer2 = 0.0
    }
    
    func checkAverage() {
//        if(showAvarage == 0) {
//            avarageLabel.alpha = 1
//            avarageLabel.textColor = UIColor.white
//            setAverage()
//        } else {
//            avarageLabel.alpha = 0
//        }
    }
    
    func setFirstProgress() {
        outterProgress.trackColor = UIColor.darkGray
        progressPer = Float(sumTime2) / Float(fixedSecond)
        beforePer = progressPer
        outterProgress.setProgressWithAnimation(duration: 1.0, value: progressPer, from: 0.0)
        //circle2
        innerProgress.trackColor = UIColor.clear
        beforePer2 = Float(sumTime)/Float(totalTime)
        innerProgress.setProgressWithAnimation(duration: 1.0, value: beforePer2, from: 0.0)
    }
    
    func firstStart() {
        let startTime = UserDefaults.standard
        startTime.set(Date(), forKey: "startTime")
        print("startTime SAVE")
        setLogData()
    }
    
    func showSettingView() {
        let setVC = storyboard?.instantiateViewController(withIdentifier: "SetTimerViewController2") as! SetTimerViewController2
            setVC.SetTimerViewControllerDelegate = self
            present(setVC,animated: true,completion: nil)
    }
    
    func showTaskView() {
        let setVC = storyboard?.instantiateViewController(withIdentifier: "taskSelectViewController") as! taskSelectViewController
            setVC.SetTimerViewControllerDelegate = self
            present(setVC,animated: true,completion: nil)
    }
    
    func startAction() {
        if(timeTrigger) {
            checkTimeTrigger()
        }
        startEnable()
        print("Start")
    }
    
    func breakStartAction() {
        if(timeTrigger) {
            breakTimeTrigger()
        }
        print("BreakStart")
    }
    
    func updateTimeLabels() {
        TIMEofSum.text = printTime(temp: sumTime)
        TIMEofStopwatch.text = printTime(temp: sumTime)
        TIMEofTarget.text = printTime(temp: goalTime)
    }
    
    func updateBreakTimeLabels() {
//        BreakTimeLabel.text = printTime(temp: breakTime)
    }
    
    func updateProgress() {
        progressPer = Float(sumTime2) / Float(fixedSecond)
        outterProgress.setProgressWithAnimation(duration: 0.0, value: progressPer, from: beforePer)
        beforePer = progressPer
        //circle2
        let temp = Float(sumTime)/Float(totalTime)
        innerProgress.setProgressWithAnimation(duration: 0.0, value: temp, from: beforePer2)
        beforePer2 = temp
    }
    
    func updateBreakProgress() {
//        progressPer = Float(breakTime2) / Float(fixedBreak)
//        CircleView.setProgressWithAnimation(duration: 0.0, value: progressPer, from: beforePer)
//        beforePer = progressPer
    }
    
    func printLogs() {
        print("second : " + String(sumTime))
        print("goalTime : " + String(goalTime))
    }
    
    func saveTimes() {
        UserDefaults.standard.set(sumTime, forKey: "sum2")
        UserDefaults.standard.set(goalTime, forKey: "allTime2")
    }
    
    func saveBreak() {
        UserDefaults.standard.set(breakTime, forKey: "breakTime")
        UserDefaults.standard.set(printTime(temp: breakTime), forKey: "break1")
    }
    
    func printTime(temp : Int) -> String {
        var returnString = "";
        var num = temp;
        if(num < 0) {
            num = -num;
            returnString += "+";
        }
        let S = num%60
        let H = num/3600
        let M = num/60 - H*60
        
        let stringS = S<10 ? "0"+String(S) : String(S)
        let stringM = M<10 ? "0"+String(M) : String(M)
        
        returnString += String(H) + ":" + stringM + ":" + stringS
        return returnString
    }
    
    func getDatas(){
        sumTime = UserDefaults.standard.value(forKey: "second") as? Int ?? 0
        print("sumTime get complite")
        goalTime = UserDefaults.standard.value(forKey: "allTime") as? Int ?? 21600
        print("goalTime get complite")
        showAvarage = UserDefaults.standard.value(forKey: "showPersent") as? Int ?? 0
        print("showAvarage get comolite")
        sumTime2 = sumTime%fixedSecond
    }
    
    func saveLogData() {
        UserDefaults.standard.set(printTime(temp: sumTime), forKey: "time1")
    }
    
    func setLogData() {
        for i in stride(from: 0, to: 7, by: 1) {
            array_day[i] = UserDefaults.standard.value(forKey: "day"+String(i+1)) as? String ?? "NO DATA"
            array_time[i] = UserDefaults.standard.value(forKey: "time"+String(i+1)) as? String ?? "NO DATA"
            array_break[i] = UserDefaults.standard.value(forKey: "break"+String(i+1)) as? String ?? "NO DATA"
        }
        //값 옮기기, 값 저장하기
        for i in stride(from: 6, to: 0, by: -1) {
            array_day[i] = array_day[i-1]
            UserDefaults.standard.set(array_day[i], forKey: "day"+String(i+1))
            array_time[i] = array_time[i-1]
            UserDefaults.standard.set(array_time[i], forKey: "time"+String(i+1))
            array_break[i] = array_break[i-1]
            UserDefaults.standard.set(array_break[i], forKey: "break"+String(i+1))
        }
        //log 날짜 설정
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일"
        let today = dateFormatter.string(from: now)
        UserDefaults.standard.set(today, forKey: "day1")
    }
    
//    private func playAudioFromProject() {
//        guard let url = Bundle.main.url(forResource: "timer", withExtension: "mp3") else {
//            print("error to get the mp3 file")
//            return
//        }
//        do {
//            audioPlayer = try AVPlayer(url: url)
//        } catch {
//            print("audio file error")
//        }
//        audioPlayer?.play()
//    }
    
    func getFutureTime() -> String {
        let now = Date()
        let future = now.addingTimeInterval(TimeInterval(goalTime))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "hh:mm a"
        let today = dateFormatter.string(from: future)
        return today
    }
    
    func stopColor() {
        self.view.backgroundColor = COLOR
        outterProgress.progressColor = UIColor.white
        innerProgress.progressColor = UIColor.black
        startStopBT.backgroundColor = RED!
//        StartButton.backgroundColor = BUTTON
//        StopButton.backgroundColor = CLICK
//        BreakButton.backgroundColor = BUTTON
//        StartButton.setTitleColor(COLOR, for: .normal)
//        StopButton.setTitleColor(UIColor.white, for: .normal)
//        BreakButton.setTitleColor(COLOR, for: .normal)
        TIMEofStopwatch.textColor = UIColor.white
        //예상종료시간 보이기, stop 버튼 제자리로 이동
        UIView.animate(withDuration: 0.3, animations: {
//            self.finishTimeLabel_show.alpha = 1
//            self.finishTimeLabel.transform = CGAffineTransform(translationX: 0, y: 0)
//            self.ModeButton.layer.borderColor = UIColor.white.cgColor
            self.settingBT.alpha = 1
        })
        //animation test
        UIView.animate(withDuration: 0.5, animations: {
            self.modeTimer.alpha = 1
            self.modeStopWatch.alpha = 1
            self.log.alpha = 1
            self.lineLeft.alpha = 1
            self.lineRight.alpha = 1
            self.taskLeft.alpha = 1
            self.taskRight.alpha = 1
//            self.StartButton.alpha = 1
//            self.BreakButton.alpha = 1
//            self.SettingButton.alpha = 1
//            self.LogButton.alpha = 1
//            self.viewLabels.alpha = 1
        })
//        self.nowTimeLabel.text = "Now Time".localized()
//        self.nowTimeLabel.alpha = 0
        self.view.layoutIfNeeded()
    }
    
    func breakStartColor() {
//        CircleView.progressColor = RED!
//        BreakTimeLabel.textColor = RED!
    }
    
    func breakStopColor() {
//        CircleView.progressColor = UIColor.white
//        BreakTimeLabel.textColor = UIColor.white
    }
    
    func startColor() {
        self.view.backgroundColor = UIColor.black
        outterProgress.progressColor = COLOR!
        innerProgress.progressColor = UIColor.white
        startStopBT.backgroundColor = UIColor.clear
//        StartButton.backgroundColor = CLICK
//        StopButton.backgroundColor = UIColor.clear
//        BreakButton.backgroundColor = CLICK
//        StartButton.setTitleColor(UIColor.white, for: .normal)
//        StopButton.setTitleColor(UIColor.white, for: .normal)
//        BreakButton.setTitleColor(UIColor.white, for: .normal)
        TIMEofStopwatch.textColor = COLOR
        //예상종료시간 숨기기, stop 버튼 센터로 이동
        UIView.animate(withDuration: 0.3, animations: {
            self.modeTimer.alpha = 0
            self.modeStopWatch.alpha = 0
            self.log.alpha = 0
            self.lineLeft.alpha = 0
            self.lineRight.alpha = 0
            self.tempBT.alpha = 0
            self.settingBT.alpha = 0
            self.taskLeft.alpha = 0
            self.taskRight.alpha = 0
//            self.finishTimeLabel_show.alpha = 0
//            self.finishTimeLabel.transform = CGAffineTransform(translationX: 0, y: -15)
//            self.StartButton.alpha = 0
//            self.BreakButton.alpha = 0
//            self.SettingButton.alpha = 0
//            self.LogButton.alpha = 0
//            self.viewLabels.alpha = 0
//            self.avarageLabel.alpha = 1
//            self.ModeButton.layer.borderColor = nil
//            self.nowTimeLabel.alpha = 1
        })
        self.view.layoutIfNeeded()
    }
    
    func stopEnable() {
//        StartButton.isUserInteractionEnabled = true
//        BreakButton.isUserInteractionEnabled = true
//        StopButton.isUserInteractionEnabled = false
        settingBT.isUserInteractionEnabled = true
        log.isUserInteractionEnabled = true
        modeTimer.isUserInteractionEnabled = true
        taskButton.isUserInteractionEnabled = true
    }
    
    func startEnable() {
//        StartButton.isUserInteractionEnabled = false
//        BreakButton.isUserInteractionEnabled = false
//        StopButton.isUserInteractionEnabled = true
        settingBT.isUserInteractionEnabled = false
        log.isUserInteractionEnabled = false
        modeTimer.isUserInteractionEnabled = false
        taskButton.isUserInteractionEnabled = false
    }
    
    func goToViewController(where: String) {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: `where`)
        vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(vcName!, animated: true, completion: nil)
    }
    
    func setColor() {
        COLOR = UserDefaults.standard.colorForKey(key: "color") as? UIColor ?? UIColor(named: "Background2")
//        StartButton.setTitleColor(COLOR, for: .normal)
//        BreakButton.setTitleColor(COLOR, for: .normal)
    }
    
    func setVCNum() {
        UserDefaults.standard.set(2, forKey: "VCNum")
    }
    
    func allStopColor() {
//        BreakButton.isUserInteractionEnabled = false
//        BreakButton.backgroundColor = CLICK
//        BreakButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func showNowTime() {
//        let now = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US")
//        dateFormatter.dateFormat = "hh:mm a"
//        let today = dateFormatter.string(from: now)
//        avarageLabel.font = UIFont(name: "HGGGothicssiP60g", size: 35)
//        nowTimeLabel.text = "\n" + "Now Time".localized()
//        avarageLabel.text = "\(today)"
    }
    
    func setLocalizable() {
        sumTimeLabel.text = "Sum Time".localized()
//        sumTimeLabel.text = "asdfsfsdfasdf"
        targetTimeLabel.text = "Target Time".localized()
        stopWatchLabel.text = "Stopwatch".localized()
    }
    
    func setTask() {
        task = UserDefaults.standard.value(forKey: "task") as? String ?? "Enter New Task"
        taskButton.setTitle(task, for: .normal)
    }
}


extension StopwatchViewController {
    
    func algoOfStart() {
        isStop = false
        startColor()
        updateProgress()
        startAction()
        finishTimeLabel.text = getFutureTime()
        if(isFirst) {
            firstStart()
            isFirst = false
        }
        showNowTime()
        //하루 그래프 데이터 생성
        daily.startTask(task)
    }
    
    func algoOfStop() {
        isStop = true
        timeTrigger = true
        realTime.invalidate()
        
        saveLogData()
        saveStopCount()
        setTimes()
        
        stopColor()
        stopEnable()
        checkAverage()
        setAverage()
        //하루 그래프 데이터 계산
        daily.stopTask()
        daily.save()
    }
    
    func algoOfBreakStart() {
//        isBreak = true
//        breakStartColor()
//        updateBreakProgress()
//        breakStartAction()
    }
    
    func algoOfBreakStop() {
//        isBreak = false
//        timeTrigger = true
//        realTime.invalidate()
//        breakStopColor()
//        //하루 그래프 데이터 저장
//        daily.save()
    }
}
