//
//  inputViewController.swift
//  taskapp
//
//  Created by ToshiyaYoneda on 2019/09/27.
//  Copyright © 2019 ToshiyaYoneda. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class inputViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBAction func createCategoryButton(_ sender: Any) {
        
    }
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    let realm = try! Realm()
    var task: Task!
    var category: Category!
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "date", ascending: false)
    var selectedCategory: Category?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return self.categoryArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedCategory = categoryArray[row]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        if categoryArray.count == 0 {
            categoryPicker.isHidden = true
        }
        categoryPicker.reloadAllComponents()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        
        if categoryArray.count != 0 {
        for i in 0..<categoryArray.count {
            if categoryArray[i] == task.category {
                categoryPicker.selectRow(i, inComponent: 0, animated: false)
                break
            }else{categoryPicker.selectRow(0, inComponent: 0, animated: false)
        }
      }
    }
        
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true) }
    
    override func viewWillDisappear(_ animated: Bool) {

        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = selectedCategory
            self.realm.add(self.task, update: true)
        }
    
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        categoryPicker.reloadAllComponents()
        
        if categoryArray.count == 0 {
            categoryPicker.isHidden = true
        }
        
    }
    
    
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
    }
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //categoryPicker.reloadAllComponents()
        if categoryArray.count != 0 {
            for i in 0..<categoryArray.count {
                if categoryArray[i] == task.category {
                    categoryPicker.selectRow(i, inComponent: 0, animated: false)
                    selectedCategory = categoryArray[i]
                    break
                }else{categoryPicker.selectRow(0, inComponent: 0, animated: false)
                    selectedCategory = categoryArray[0]
                }
            }
        }

        
    }
    
}
