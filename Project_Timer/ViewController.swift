//
//  ViewController.swift
//  Project_Timer
//
//  Created by Min_MacBook Pro on 2020/06/08.
//  Copyright © 2020 FDEE. All rights reserved.
//

//  간단한 타이머 어플 코드입니다
//  1초마다 updateCounter() 실행되며 목표시간인 AllTime은 -1, 누적시간인 sum은 +1, 타이머 시간인 second는 -1됩니다
//  시간이 변경됨과 동시에 저장이 이루어 져 어플을 나갔다 와도 정보가 남아있습니다
//  시작, 정지 버튼과 더불어 타이머시간을 재설정하는 ResetButton, 목표시간과 누적시간을 초기화하는 RESETButton,
//  새로운 목표시간과 타이머 시간을 설정하는 TimeSETButton 이 있습니다
//  setViewController 에서 목표시간과 타이머 시간을 설정할 수 있습니다
//  그외 기능들은 화면색 변경, 소리알림, 시간으로 표시하는 기타기능들 입니다

//  *** 혹시 코드를 수정시에 절때 지우시지 말고 주석으로 지우고, 새로 수정시 주석을 남기시기 바랍니다 ***
//  Copyright © 2020 FDEE.

import UIKit


import AudioToolbox
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var GoalTimeLabel: UILabel!
    @IBOutlet var SumTimeLabel: UILabel!
    @IBOutlet var CountTimeLabel: UILabel!
    @IBOutlet var StartButton: UIButton!
    @IBOutlet var StopButton: UIButton!
    @IBOutlet var ResetButton: UIButton!
    @IBOutlet var SettingButton: UIButton!
    @IBOutlet var TimerButton: UIButton!
    @IBOutlet var AverageLabel: UILabel!
    @IBOutlet var LogButton: UIButton!
    @IBOutlet var finishTimeLabel_show: UILabel!
    @IBOutlet var finishTimeLabel: UILabel!
    @IBOutlet var viewLabels: UIView!
    @IBOutlet var CircleView: CircularProgressView!
    @IBOutlet var ModeButton: UIButton!
    
    let BLUE = UIColor(named: "Blue")
    let BUTTON = UIColor(named: "Button")
    let CLICK = UIColor(named: "Click")
    let TEXT = UIColor(named: "Text")
    
    var audioPlayer : AVPlayer!
    var timeTrigger = true
    var realTime = Timer()
    var timerTime : Int = 0
    var sumTime : Int = 0
    var goalTime : Int = 0
    var diffHrs = 0
    var diffMins = 0
    var diffSecs = 0
    var isStop = true
    var isRESET = false
    var progressPer: Float = 0.0
    var fixedSecond: Int = 0
    var fromSecond: Float = 0.0
    var showAverage: Int = 0
    var array_day = [String](repeating: "", count: 7)
    var array_time = [String](repeating: "", count: 7)
    var stopCount: Int = 0
    var VCNum: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVCNum()
        setRadius()
        setBorner()
        getDatas()
        
        updateTimeLabels()
        stopColor()
        stopEnable()
        
        setBackground()
        setIsFirst()
        checkAverage()
        setProgress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //로그인이 이미 되어있는 경우라면 홈페이지로 이동한다.
        if(VCNum == 2) {
            goToViewController(where: "ViewController2")
        }
    }
    
    @IBAction func StartButtonAction(_ sender: UIButton) {
        //persent 추가! RESET 후 시작시 시작하는 시간 저장!
        if(isRESET)
        {
            let startTime = UserDefaults.standard
            startTime.set(Date(), forKey: "startTime")
            print("startTime SAVE")
            isRESET = false
            fixedSecond = UserDefaults.standard.value(forKey: "second") as? Int ?? 2400
            //log 추가
            setLogData()
        }
        startColor()
        startAction()
        isStop = false
        finishTimeLabel.text = getFutureTime()
    }
    
    @IBAction func StopButtonAction(_ sender: UIButton) {
        isStop = true
        endGame()
        stopColor()
        stopEnable()
    }
    
    @IBAction func ResetButtonAction(_ sender: UIButton) {
        ResetButton.backgroundColor = CLICK
        ResetButton.setTitleColor(UIColor.white, for: .normal)
        ResetButton.isUserInteractionEnabled = false
        
        isStop = true
        timerTime = UserDefaults.standard.value(forKey: "second") as? Int ?? 2400
        UserDefaults.standard.set(timerTime, forKey: "second2")
        print("reset Button complite")
        CountTimeLabel.text = printTime(temp: timerTime)
        SumTimeLabel.text = printTime(temp: sumTime)
        print("print Time complite")
        
        //프로그래스 추가!
        CircleView.setProgressWithAnimation(duration: 1.0, value: 0.0, from: fromSecond)
        fromSecond = 0.0
        //종료예상시간 보이기
        finishTimeLabel.text = getFutureTime()
    }
    
    @IBAction func SETTINGButton(_ sender: UIButton) {
        let setVC = storyboard?.instantiateViewController(withIdentifier: "SetViewController") as! SetViewController
            setVC.setViewControllerDelegate = self
            present(setVC,animated: true,completion: nil)
    }
    
    //타이머 설정 버튼 추가
    @IBAction func TIMERButton(_ sender: UIButton) {
        let setVC = storyboard?.instantiateViewController(withIdentifier: "SetTimerViewController") as! SetTimerViewController
            setVC.SetTimerViewControllerDelegate = self
            present(setVC,animated: true,completion: nil)
    }
    @IBAction func ModeBTAction(_ sender: UIButton) {
        goToViewController(where: "ViewController2")
    }
    
    
    @objc func updateCounter(){
        if timerTime < 61 {
            CountTimeLabel.textColor = TEXT
            CircleView.progressColor = TEXT!
        }
        if timerTime < 1 {
            endGame()
            stopColor()
            stopEnable()
            CountTimeLabel.text = "종료"
//            AudioServicesPlaySystemSound(1254)
            //오디오 재생 추가
            playAudioFromProject()
//            AudioServicesPlaySystemSound(4095)
        }
        else {
            timerTime = timerTime - 1
            sumTime = sumTime + 1
            goalTime = goalTime - 1
            setPerSeconds()
        }
        
    }
    
    func checkTimeTrigger() {
        realTime = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        timeTrigger = false
    }
    
    func endGame() {
        isStop = true
        realTime.invalidate()
        timeTrigger = true
        //log 저장
        saveLogData()
        //stopCount 증가
        stopCount+=1
        UserDefaults.standard.set(stopCount, forKey: "stopCount")
        checkPersent()
        //종료예상시간 보이기
        finishTimeLabel.text = getFutureTime()
    }
    
    func printTime(temp : Int) -> String
    {
        var returnString = "";
        var num = temp;
        if(num < 0)
        {
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
    
    //클래스 불러오는 메소드 영역
    func getTimeData(){
        timerTime = UserDefaults.standard.value(forKey: "second") as? Int ?? 2400
        print("second set complite")
        goalTime = UserDefaults.standard.value(forKey: "allTime") as? Int ?? 21600
        print("allTime set complite")
        //빡공률 보이기 설정
        showAverage = UserDefaults.standard.value(forKey: "showPersent") as? Int ?? 0
    }
    
    
}

extension ViewController : ChangeViewController {
    
    func updateViewController() {
        stopColor()
        stopEnable()
        ResetButton.backgroundColor = CLICK
        ResetButton.setTitleColor(UIColor.white, for: .normal)
        ResetButton.isUserInteractionEnabled = false
        
//        endGame()
        isStop = true
        realTime.invalidate()
        timeTrigger = true
        getTimeData()
        sumTime = 0
        print("reset Button complite")
        
        UserDefaults.standard.set(timerTime, forKey: "second2")
        UserDefaults.standard.set(goalTime, forKey: "allTime2")
        UserDefaults.standard.set(sumTime, forKey: "sum2")
        UserDefaults.standard.set(0, forKey: "breakTime")
        //정지 회수 저장
        stopCount = 0
        UserDefaults.standard.set(0, forKey: "stopCount")
        AverageLabel.text = "STOP : " + String(stopCount) + "\nAVER : 0:00:00"
        
        GoalTimeLabel.text = printTime(temp: goalTime)
        SumTimeLabel.text = printTime(temp: sumTime)
        CountTimeLabel.text = printTime(temp: timerTime)
        
        persentReset()
        //빡공률 보이기 설정
        if(showAverage == 0)
        {
            AverageLabel.alpha = 1
        }
        else
        {
            AverageLabel.alpha = 0
        }
        //종료 예상시간 보이기
        finishTimeLabel.text = getFutureTime()
    }
    
    func changeTimer() {
        timerTime = UserDefaults.standard.value(forKey: "second") as? Int ?? 2400
        UserDefaults.standard.set(timerTime, forKey: "second2")
        CountTimeLabel.text = printTime(temp: timerTime)
        finishTimeLabel.text = getFutureTime()
        fixedSecond = UserDefaults.standard.value(forKey: "second") as? Int ?? 2400
        CircleView.setProgressWithAnimation(duration: 1.0, value: 0.0, from: fromSecond)
        fromSecond = 0.0
    }
    
    // Selected for Lifecycle Methods
        @objc func pauseWhenBackground(noti: Notification) {
            print("background")
            if(!isStop)
            {
                realTime.invalidate()
                timeTrigger = true
                let shared = UserDefaults.standard
                shared.set(Date(), forKey: "savedTime")
            }
        }
    
    @objc func willEnterForeground(noti: Notification) {
        print("Enter")
        if(!isStop)
        {
            if let savedDate = UserDefaults.standard.object(forKey: "savedTime") as? Date {
                (diffHrs, diffMins, diffSecs) = ViewController.getTimeDifference(startDate: savedDate)
                refresh(hours: diffHrs, mins: diffMins, secs: diffSecs)
                removeSavedDate()
            }
        }
        //백그라운드 진입시 다시 최신화 설정
        finishTimeLabel.text = getFutureTime()
    }
    
    static func getTimeDifference(startDate: Date) -> (Int, Int, Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
        return(components.hour!, components.minute!, components.second!)
    }
    
    func refresh (hours: Int, mins: Int, secs: Int) {
        let tempSeconds = hours*3600 + mins*60 + secs
        let temp = timerTime-tempSeconds;
        
        if(timerTime - tempSeconds < 0)
        {
            goalTime = goalTime - tempSeconds
            sumTime = sumTime + tempSeconds
            timerTime = 0
        }
        else
        {
            goalTime = goalTime - tempSeconds
            sumTime = sumTime + tempSeconds
            timerTime = timerTime - tempSeconds
        }
        setPerSeconds()
        startAction()
        if(timerTime - tempSeconds < 0)
        {
            CountTimeLabel.text = printTime(temp: temp)
        }
    }
    
    func removeSavedDate() {
        if (UserDefaults.standard.object(forKey: "savedTime") as? Date) != nil {
            UserDefaults.standard.removeObject(forKey: "savedTime")
        }
    }
    
    func startAction()
    {
        if timeTrigger { checkTimeTrigger() }
        startEnable()
        print("Start")
    }
    
    func setPerSeconds()
    {
        GoalTimeLabel.text = printTime(temp: goalTime)
        SumTimeLabel.text = printTime(temp: sumTime)
        CountTimeLabel.text = printTime(temp: timerTime)
        print("update : " + String(timerTime))
        UserDefaults.standard.set(sumTime, forKey: "sum2")
        UserDefaults.standard.set(timerTime, forKey: "second2")
        UserDefaults.standard.set(goalTime, forKey: "allTime2")
        
        //persent 추가!
//        checkPersent()
        //프로그래스 추가!
        progressPer = Float(fixedSecond - timerTime) / Float(fixedSecond)
        print("fixedSecond : " + String(fixedSecond))
        print("second : " + String(timerTime))
        CircleView.setProgressWithAnimation(duration: 0.0, value: progressPer, from: fromSecond)
        fromSecond = progressPer
    }
    
    func persentReset()
    {
        isRESET = true
//        persentLabel.text = "빡공률 : 0.0%"
        AverageLabel.textColor = UIColor.white
        //프로그래스 추가!
        fixedSecond = UserDefaults.standard.value(forKey: "second") as? Int ?? 2400
        CircleView.setProgressWithAnimation(duration: 1.0, value: 0.0, from: fromSecond)
        fromSecond = 0.0
    }
    
    //빡공률 -> 종료회수, 평균시간 보이기로 변경
    func checkPersent()
    {
        //정지회수 보이기
        var print = "STOP : " + String(stopCount)
        let aver = (Int)(sumTime/stopCount)
        print += "\nAVER : " + printTime(temp: aver)
        //정지회수, 평균 시간 보이기
        AverageLabel.text = print
    }
    
    func stopColor()
    {
        self.view.backgroundColor = BLUE
        CircleView.progressColor = UIColor.white
        StartButton.backgroundColor = BUTTON
        StopButton.backgroundColor = CLICK
        ResetButton.backgroundColor = BUTTON
        StartButton.setTitleColor(BLUE, for: .normal)
        StopButton.setTitleColor(UIColor.white, for: .normal)
        ResetButton.setTitleColor(BLUE, for: .normal)
        CountTimeLabel.textColor = UIColor.white
        //예상종료시간 보이기, stop 버튼 제자리로 이동
        UIView.animate(withDuration: 0.3, animations: {
            self.finishTimeLabel_show.alpha = 1
            self.finishTimeLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.ModeButton.layer.borderColor = UIColor.white.cgColor
        })
        //animation test
        UIView.animate(withDuration: 0.5, animations: {
            self.StartButton.alpha = 1
            self.ResetButton.alpha = 1
            self.SettingButton.alpha = 1
            self.TimerButton.alpha = 1
            self.LogButton.alpha = 1
            self.viewLabels.alpha = 1
        })
        //보이기 숨기기 설정
        if(showAverage == 0)
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.AverageLabel.alpha = 1
            })
        }
    }
    
    func startColor()
    {
        self.view.backgroundColor = UIColor.black
        CircleView.progressColor = BLUE!
        StartButton.backgroundColor = CLICK
        StopButton.backgroundColor = UIColor.clear
        ResetButton.backgroundColor = CLICK
        StartButton.setTitleColor(UIColor.white, for: .normal)
        StopButton.setTitleColor(UIColor.white, for: .normal)
        ResetButton.setTitleColor(UIColor.white, for: .normal)
        CountTimeLabel.textColor = BLUE
        //예상종료시간 숨기기, stop 버튼 센터로 이동
        UIView.animate(withDuration: 0.3, animations: {
            self.finishTimeLabel_show.alpha = 0
            self.finishTimeLabel.transform = CGAffineTransform(translationX: 0, y: -15)
            self.StartButton.alpha = 0
            self.ResetButton.alpha = 0
            self.SettingButton.alpha = 0
            self.TimerButton.alpha = 0
            self.LogButton.alpha = 0
            self.viewLabels.alpha = 0
            self.AverageLabel.alpha = 0
            self.ModeButton.layer.borderColor = nil
        })
    }
    
    func stopEnable()
    {
        StartButton.isUserInteractionEnabled = true
        ResetButton.isUserInteractionEnabled = true
        StopButton.isUserInteractionEnabled = false
        SettingButton.isUserInteractionEnabled = true
        TimerButton.isUserInteractionEnabled = true
        LogButton.isUserInteractionEnabled = true
        ModeButton.isUserInteractionEnabled = true
    }
    
    func startEnable()
    {
        StartButton.isUserInteractionEnabled = false
        ResetButton.isUserInteractionEnabled = false
        StopButton.isUserInteractionEnabled = true
        SettingButton.isUserInteractionEnabled = false
        TimerButton.isUserInteractionEnabled = false
        LogButton.isUserInteractionEnabled = false
        ModeButton.isUserInteractionEnabled = false
    }
    
    func saveLogData()
    {
        //log 시간 저장
        UserDefaults.standard.set(printTime(temp: sumTime), forKey: "time1")
    }
    
    func setLogData()
    {
        //값 불러오기
        for i in stride(from: 0, to: 7, by: 1)
        {
            array_day[i] = UserDefaults.standard.value(forKey: "day"+String(i+1)) as? String ?? "NO DATA"
            array_time[i] = UserDefaults.standard.value(forKey: "time"+String(i+1)) as? String ?? "NO DATA"
        }
        //값 옮기기, 값 저장하기
        for i in stride(from: 6, to: 0, by: -1)
        {
            array_day[i] = array_day[i-1]
            UserDefaults.standard.set(array_day[i], forKey: "day"+String(i+1))
            array_time[i] = array_time[i-1]
            UserDefaults.standard.set(array_time[i], forKey: "time"+String(i+1))
        }
        
        //log 날짜 설정
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일"
        let today = dateFormatter.string(from: now)
        UserDefaults.standard.set(today, forKey: "day1")
    }
    private func playAudioFromProject() {
        guard let url = Bundle.main.url(forResource: "timer", withExtension: "mp3") else {
            print("error to get the mp3 file")
            return
        }
        do {
            audioPlayer = try AVPlayer(url: url)
        } catch {
            print("audio file error")
        }
        audioPlayer?.play()
    }
    
    //예정종료시간 구하기
    func getFutureTime() -> String
    {
        //log 날짜 설정
        let now = Date()
        let future = now.addingTimeInterval(TimeInterval(timerTime))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let today = dateFormatter.string(from: future)
        return today
    }
    
    func RESET_action()
    {
        ResetButton.backgroundColor = CLICK
        ResetButton.setTitleColor(UIColor.white, for: .normal)
        ResetButton.isUserInteractionEnabled = false
        
        isStop = true
        endGame()
        getTimeData()
        sumTime = 0
        timeTrigger = true
        realTime = Timer()
        print("reset Button complite")
        
        UserDefaults.standard.set(timerTime, forKey: "second2")
        UserDefaults.standard.set(goalTime, forKey: "allTime2")
        UserDefaults.standard.set(sumTime, forKey: "sum2")
        //정지 회수 저장
        stopCount = 0
        UserDefaults.standard.set(0, forKey: "stopCount")
        AverageLabel.text = "STOP : " + String(stopCount) + "\nAVER : 0:00:00"
        
        GoalTimeLabel.text = printTime(temp: goalTime)
        SumTimeLabel.text = printTime(temp: sumTime)
        CountTimeLabel.text = printTime(temp: timerTime)
        
        //persent 추가! RESET 여부 추가
        persentReset()
        //예상종료시간 보이기
        finishTimeLabel.text = getFutureTime()
    }

}



extension ViewController {
    
    func setBackground() {
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func setIsFirst() {
        if (UserDefaults.standard.object(forKey: "startTime") == nil) {
            isRESET = true
        }
    }
    
    func checkAverage() {
        if(showAverage == 0) {
            AverageLabel.alpha = 1
            AverageLabel.textColor = UIColor.white
            setAverage()
        } else {
            AverageLabel.alpha = 0
        }
    }
    
    func setAverage() {
        if(stopCount == 0) {
            AverageLabel.text = "STOP : " + String(stopCount) + "\nAVER : 0:00:00"
        } else {
            var print = "STOP : " + String(stopCount)
            let aver = (Int)(sumTime/stopCount)
            print += "\nAVER : " + printTime(temp: aver)
            AverageLabel.text = print
        }
    }
    
    func setRadius() {
        ModeButton.layer.cornerRadius = 10
        StartButton.layer.cornerRadius = 10
        StopButton.layer.cornerRadius = 10
        ResetButton.layer.cornerRadius = 10
    }
    
    func getDatas() {
        sumTime = UserDefaults.standard.value(forKey: "sum2") as? Int ?? 0
        goalTime = UserDefaults.standard.value(forKey: "allTime2") as? Int ?? 21600
        timerTime = UserDefaults.standard.value(forKey: "second2") as? Int ?? 2400
        showAverage = UserDefaults.standard.value(forKey: "showPersent") as? Int ?? 0
        stopCount = UserDefaults.standard.value(forKey: "stopCount") as? Int ?? 0
        fixedSecond = UserDefaults.standard.value(forKey: "second") as? Int ?? 2400
    }
    
    func setBorner() {
        ModeButton.layer.borderWidth = 3
        ModeButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func goToViewController(where: String) {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: `where`)
        vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(vcName!, animated: true, completion: nil)
    }
    
    func getVCNum() {
        VCNum = UserDefaults.standard.value(forKey: "VCNum") as? Int ?? 1
    }
    
    func setProgress() {
        CircleView.trackColor = UIColor.darkGray
        progressPer = Float(fixedSecond - timerTime) / Float(fixedSecond)
        fromSecond = progressPer
        CircleView.setProgressWithAnimation(duration: 1.0, value: progressPer, from: 0.0)
    }
    
    func updateTimeLabels() {
        GoalTimeLabel.text = printTime(temp: goalTime)
        CountTimeLabel.text = printTime(temp: timerTime)
        SumTimeLabel.text = printTime(temp: sumTime)
        finishTimeLabel.text = getFutureTime()
    }
}
