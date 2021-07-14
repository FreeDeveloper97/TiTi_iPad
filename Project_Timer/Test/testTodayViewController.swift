//
//  testTodayViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/07/10.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit
import SwiftUI

class testTodayViewController: UIViewController {

    @IBOutlet var frame: UIView!
    @IBOutlet var innerView: UIView!
    @IBOutlet var today: UILabel!
    @IBOutlet var timeline: UIView!
    @IBOutlet var sumTime: UILabel!
    @IBOutlet var maxTime: UILabel!
    @IBOutlet var progress: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var todo_collectionView: UICollectionView!
    
    @IBOutlet var rightBottomHeight: NSLayoutConstraint! //355 <-> 420
    @IBOutlet var todolistTopMargin: NSLayoutConstraint! //5 <-> 5+(194+5)
    @IBOutlet var tilelineWidth: NSLayoutConstraint! //455 <-> 455+(253+5)
    
    @IBOutlet var mon: UIView!
    @IBOutlet var tue: UIView!
    @IBOutlet var wed: UIView!
    @IBOutlet var thu: UIView!
    @IBOutlet var fri: UIView!
    @IBOutlet var sat: UIView!
    @IBOutlet var sun: UIView!
    
    @IBOutlet var color1: UIButton!
    @IBOutlet var color2: UIButton!
    @IBOutlet var color3: UIButton!
    @IBOutlet var color4: UIButton!
    @IBOutlet var color5: UIButton!
    @IBOutlet var color6: UIButton!
    @IBOutlet var color7: UIButton!
    @IBOutlet var color8: UIButton!
    @IBOutlet var color9: UIButton!
    @IBOutlet var color10: UIButton!
    @IBOutlet var color11: UIButton!
    @IBOutlet var color12: UIButton!
    
    @IBOutlet var selectDayBT: UIButton!
    @IBOutlet var selectDay: UILabel!
    @IBOutlet var selectDayBgView: UIView!
    
    let todayViewManager = TodayViewManager()
    var weeks: [UIView] = []
    
    let todoListViewModel = TodolistViewModel()
    
    var dateIndex: Int?
    let dateFormatter = DateFormatter()
    let dailyViewModel = DailyViewModel()
    
    var isDumy: Bool = false
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        super.viewDidLoad()
        self.hideKeyboard()
        
        weeks = [sun, mon, tue, wed, thu, fri, sat]
        
        todayViewManager.getColor()
        setRadius()
        setShadow(innerView)
        setShadowDayBgView()
        //저장된 dailys들 로딩
        dailyViewModel.loadDailys()
        
        getColor()
        isDumy = false //앱스토어 스크린샷을 위한 더미데이터 여부
        showDatas(isDumy: isDumy)
        //showSwiftUIGraph(isDumy: isDumy) -> checkRotate 내로 이동
        
        todoListViewModel.loadTodos()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        checkRotate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        todayContentView().reset()
    }
    
    @objc func deviceRotated(){
        afterRotate()
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
        let i = Int(sender.tag)
        todayViewManager.setStartColorIndex(i)
        
        reset()
    }
    
    @IBAction func showCalendar(_ sender: Any) {
        showCalendar()
    }
    
    @IBAction func addList(_ sender: Any) {
        let alert = UIAlertController(title: "Add new Todo".localized(), message: "Enter a subject that's max length is 20".localized(), preferredStyle: .alert)
        let cancle = UIAlertAction(title: "CANCLE", style: .default, handler: nil)
        let ok = UIAlertAction(title: "ENTER", style: .destructive, handler: {
            action in
            guard let newTodo: String = alert.textFields?[0].text, newTodo.isEmpty == false else { return }
            let todo = TodoManager.shared.createTodo(text: newTodo)
            self.todoListViewModel.addTodo(todo)
            
            self.todo_collectionView.reloadData()
        })
        //텍스트 입력 추가
        alert.addTextField { (inputNewNickName) in
            inputNewNickName.placeholder = "Add new Todo".localized()
            inputNewNickName.textAlignment = .center
            inputNewNickName.font = UIFont(name: "HGGGothicssiP60g", size: 17)
        }
        alert.addAction(ok)
        alert.addAction(cancle)
        present(alert,animated: true,completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        todayViewManager.saveImage(view)
        showAlert()
    }
}


extension testTodayViewController {
    
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
        showSwiftUIGraph(isDumy: isDumy)
    }
    
    func afterRotate() {
        todayContentView().reset()
        for view in self.timeline.subviews {
            view.removeFromSuperview()
        }
        if UIDevice.current.orientation.isPortrait {
            //Code here
            print("Portrait")
            setPortrait()
        } else if UIDevice.current.orientation.isLandscape {
            //Code here
            print("Landscape")
            setLandscape()
        } else { }
        showSwiftUIGraph(isDumy: isDumy)
    }
    
    func setPortrait() {
        rightBottomHeight.constant = 380
        todolistTopMargin.constant = 204
        tilelineWidth.constant = 713
        view.layoutIfNeeded()
    }
    
    func setLandscape() {
        rightBottomHeight.constant = 355
        todolistTopMargin.constant = 5
        tilelineWidth.constant = 455
        view.layoutIfNeeded()
    }
    
    func setRadius() {
        innerView.layer.cornerRadius = 25
        
        color1.layer.cornerRadius = 5
        color2.layer.cornerRadius = 5
        color3.layer.cornerRadius = 5
        color4.layer.cornerRadius = 5
        color5.layer.cornerRadius = 5
        color6.layer.cornerRadius = 5
        color7.layer.cornerRadius = 5
        color8.layer.cornerRadius = 5
        color9.layer.cornerRadius = 5
        color10.layer.cornerRadius = 5
        color11.layer.cornerRadius = 5
        color12.layer.cornerRadius = 5
        
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
        selectDayBgView.layer.shadowColor = todayViewManager.COLOR.cgColor
        selectDayBgView.layer.shadowOpacity = 0.5
        selectDayBgView.layer.shadowOffset = CGSize.zero
        selectDayBgView.layer.shadowRadius = 5.5
        
        selectDay.layer.shadowColor = todayViewManager.COLOR.cgColor
        selectDay.layer.shadowOpacity = 1
        selectDay.layer.shadowOffset = CGSize(width: 1, height: 0.5)
        selectDay.layer.shadowRadius = 1.5
    }
    
    func getColor() {
        todayViewManager.startColor = UserDefaults.standard.value(forKey: "startColor") as? Int ?? 1
    }
    
    func showAlert() {
        let alert = UIAlertController(title:"Save completed".localized(),
            message: "",
            preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func showSwiftUIGraph(isDumy: Bool) {
        let startColor = todayViewManager.startColor
        let colorNow: Int = startColor
        var colorSecond: Int = 0
        if(!todayViewManager.reverseColor) {
            colorSecond = startColor+1 == 13 ? 1 : startColor+1
        } else {
            colorSecond = startColor-1 == 0 ? 12 : startColor-1
        }
        //frame1
        let height: CGFloat = 168
        let hostingController = UIHostingController(rootView: todayContentView(colors: [Color("D\(colorSecond)"), Color("D\(colorNow)")], frameHeight: height, height: height-3, fontSize: 12))
        hostingController.view.translatesAutoresizingMaskIntoConstraints = true
        hostingController.view.frame = timeline.bounds
        todayContentView().appendTimes(isDumy: isDumy, daily: todayViewManager.daily)
        
        addChild(hostingController)
        timeline.addSubview(hostingController.view)
    }
    
    func showDatas(isDumy: Bool) {
        if(dateIndex == nil) {
            todayViewManager.daily.load()
        } else {
            //배열에 있는 daily 보이기
            todayViewManager.daily = dailyViewModel.dailys[dateIndex!]
        }
        
        if(isDumy) {
            todayViewManager.setDumyDaily()
        }
        if(todayViewManager.daily.tasks != [:]) {
            todayViewManager.setTasksColor()
            todayViewManager.setDay(today)
            todayViewManager.setWeek(weeks)
            todayViewManager.getTasks()
            todayViewManager.makeProgress(progress)
            todayViewManager.showTimes(sumTime, maxTime)
        } else {
            todayViewManager.setTimesColor(sumTime, maxTime)
            print("no data")
        }
    }
    
    func showCalendar() {
        let setVC = storyboard?.instantiateViewController(withIdentifier: "calendarViewController") as! calendarViewController
        setVC.calendarViewControllerDelegate = self
        present(setVC,animated: true,completion: nil)
    }
    
    func reset() {
        for view in self.progress.subviews {
            view.removeFromSuperview()
        }
        
        todayViewManager.reset()
        todayContentView().reset()
        self.viewDidLoad()
        self.view.layoutIfNeeded()
        collectionView.reloadData()
        todo_collectionView.reloadData()
    }
}


extension testTodayViewController: selectCalendar {
    func getDailyIndex() {
        dateIndex = UserDefaults.standard.value(forKey: "dateIndex") as? Int ?? nil
        selectDay.text = dateFormatter.string(from: dailyViewModel.dates[dateIndex!])
        reset()
    }
}


extension testTodayViewController: UICollectionViewDataSource {
    //몇개 표시 할까?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.todo_collectionView) {
            return todoListViewModel.todos.count
        } else {
            return todayViewManager.counts
        }
    }
    //셀 어떻게 표시 할까?
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.collectionView) {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath) as? todayCell else {
                return UICollectionViewCell()
            }
            let counts = todayViewManager.counts
            let color = todayViewManager.colors[counts - indexPath.item - 1]
            cell.check.textColor = color
            cell.taskName.text = todayViewManager.arrayTaskName[counts - indexPath.item - 1]
            cell.taskTime.text = todayViewManager.arrayTaskTime[counts - indexPath.item - 1]
            cell.taskTime.textColor = color
            cell.background.backgroundColor = color
            
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoCell", for: indexPath) as? TodoCell else {
                return UICollectionViewCell() }
            
            var todo = todoListViewModel.todos[indexPath.item]
            let index = todayViewManager.startColor
            cell.check.tintColor = UIColor(named: "D\(index)")
            cell.colorView.backgroundColor = UIColor(named: "D\(index)")
            cell.updateUI(todo: todo)
            self.view.layoutIfNeeded()
            
            cell.doneButtonTapHandler = { isDone in
                todo.isDone = isDone
                self.todoListViewModel.updateTodo(todo)
                self.todo_collectionView.reloadData()
            }
            
            cell.deleteButtonTapHandler = {
                self.todoListViewModel.deleteTodo(todo)
                self.todo_collectionView.reloadData()
            }
            
            return cell
        }
        
    }
}

class todayCell: UICollectionViewCell {
    @IBOutlet var check: UILabel!
    @IBOutlet var taskName: UILabel!
    @IBOutlet var taskTime: UILabel!
    @IBOutlet var background: UIView!
}

class TodoCell: UICollectionViewCell {
    @IBOutlet weak var check: UIButton!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var delete: UIButton!
    
    var doneButtonTapHandler: ((Bool) -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    
    @IBAction func checkTapped(_ sender: Any) {
        check.isSelected = !check.isSelected
        let isDone = check.isSelected
        showColorView(isDone)
        delete.isHidden = !isDone
        doneButtonTapHandler?(isDone)
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        deleteButtonTapHandler?()
    }
    
    func reset() {
        delete.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func updateUI(todo: Todo) {
        check.isSelected = todo.isDone
        text.text = todo.text
        delete.isHidden = todo.isDone == false
        showColorView(todo.isDone)
    }
    
    private func showColorView(_ show: Bool) {
        if show {
            colorView.alpha = 0.5
        } else {
            colorView.alpha = 0
        }
    }
    
    
}
