//
//  taskSelectViewController.swift
//  Project_Timer
//
//  Created by Kang Minsang on 2021/04/05.
//  Copyright © 2021 FDEE. All rights reserved.
//

import UIKit

class taskSelectViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    var tasks: [String] = []
    var SetTimerViewControllerDelegate : ChangeViewController2!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 1...10 {
            tasks.append("task\(i)")
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tasks(_ sender: UIButton) {
        let task = sender.title(for: .normal)!
        setTask(task)
    }
    
    @IBAction func test_new(_ sender: Any) {
        let alert = UIAlertController(title: "새로운 과목 입력", message: "15자리 내의 새로운 과목을 입력하세요", preferredStyle: .alert)
        let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
        let ok = UIAlertAction(title: "입력", style: .destructive, handler: {
            action in
            let newTask: String = alert.textFields?[0].text ?? ""
            // 위 변수를 통해 특정기능 수행
            self.setTask(newTask)
        })
        //텍스트 입력 추가
        alert.addTextField { (inputNewNickName) in
            inputNewNickName.placeholder = "새로운 과목 입력"
            inputNewNickName.textAlignment = .center
            inputNewNickName.font = UIFont(name: "HGGGothicssiP60g", size: 17)
        }
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func setTask(_ task: String) {
        UserDefaults.standard.set(task, forKey: "task")
        SetTimerViewControllerDelegate.changeTask()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension taskSelectViewController: UITableViewDataSource, UITableViewDelegate {
    //몇개 표시 할까?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    //셀 어떻게 표시 할까?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath) as? taskListCell else {
            return UITableViewCell()
        }
        cell.taskName.text = tasks[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.tasks.remove(at: indexPath.row)
            self.table.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [deleteAction]
    }
}

class taskListCell: UITableViewCell {
    @IBOutlet var taskName: UILabel!
}

//extension taskSelectViewController: UICollectionViewFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width: CGFloat = collectionView.bounds.width
//        let height: CGFloat = 100
//        return CGSize(width: width, height: height)
//    }
//}
