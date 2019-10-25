//
//  ViewController.swift
//  taskapp
//
//  Created by ToshiyaYoneda on 2019/09/25.
//  Copyright © 2019 ToshiyaYoneda. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    var searchResult = [String]()
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "date", ascending: false)
    var searchBar = UISearchBar()
    let cell = UITableViewCell()


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        //searchBar.delegate = self
        
        //searchBar.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:42)
        //searchBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 89)
        //searchBar.searchBarStyle = UISearchBar.Style.default
        //searchBar.showsSearchResultsButton = false
        
        //tableView.tableHeaderView = searchBar
        //searchBar.placeholder = "Categoryを選択"
        //searchBar.showsScopeBar = true
        //searchBar.scopeButtonTitles = ["work"]
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        
        
        
    }
    
    @IBAction func categorySearch(_ sender: Any) {
        
        let actionSheet: UIAlertController = UIAlertController(
            title: "Categoryを選択してください",
            message: nil,
            preferredStyle: UIAlertController.Style.actionSheet)
        
        for category in categoryArray {
            actionSheet.addAction(UIAlertAction(title: category.name,style: .default,
                                                handler: {
                                                    (action: UIAlertAction!) -> Void in
                                                    let predicate = NSPredicate(format: "category.name = %@", category.name)
                                                    self.taskArray = try! Realm().objects(Task.self).filter(predicate)
                                                    self.tableView.reloadData()
            })
            )
        }
        
        actionSheet.addAction(UIAlertAction(title: "全てのタスクを表示",style: .default,
                                            handler: {
                                                (action: UIAlertAction!) -> Void in
                                                self.taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
                                                self.tableView.reloadData()
        })
        )
        
        
        
        let cancel = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            
        })
        
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    

    // 検索ボタンが押された時に呼ばれる
    //func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //    self.view.endEditing(true)
    //    searchBar.showsCancelButton = true
        
    //    let predicate = NSPredicate(format: "category.name = %@", searchBar.text ?? "")
    //    taskArray = try! Realm().objects(Task.self).filter(predicate)
        
    //    self.tableView.reloadData()
    //}
    
    //func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       //searchBar.text = ""
    //   taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    //   tableView.reloadData()

    //}
    
    //func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //    if searchBar.text == ""{
    //        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    //        tableView.reloadData()
    //    }
    //}
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        //let titlecategory = "Title:\(task.title),Category:\(task.category!.name)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: task.date)

        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)

        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:inputViewController = segue.destination as! inputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
                
            }
            
            inputViewController.task = task
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
    }
    
    
    
}

