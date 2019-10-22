//
//  CategoryViewController.swift
//  taskapp
//
//  Created by ToshiyaYoneda on 2019/10/08.
//  Copyright © 2019 ToshiyaYoneda. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    let realm = try! Realm()
    let task =  Task()
    let category = Category()
    var CreateCategoryText: UITextField!
    let cell = UITableViewCell()
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "date", ascending: false)
    
    //alertの設定（ここに新しいcategoryを設定）
    @IBAction func Save(_ sender: Any) {
        let alert = UIAlertController( title: "Categoryを作成しますか？",message: "入力してください。", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField( configurationHandler: { ( create: UITextField!) -> Void in create.placeholder = "Category?"})
        
        let defaultAction : UIAlertAction = UIAlertAction(title: "OK",style: UIAlertAction.Style.default,handler: {(action: UIAlertAction!) -> Void in
            
                let att = alert.textFields![0].text!

            try!self.realm.write {
                let allCategorys = self.realm.objects(Category.self)
                if allCategorys.count != 0 {
                    self.category.id = allCategorys.max(ofProperty: "id")! + 1
                }
                    self.category.name = att
                    self.category.date = Date()

                self.realm.add(self.category, update: true)
                
            }
            self.categoryTableView.reloadData()
            self.navigationController?.popViewController(animated: true)
        })
        
        
        let cancelAction :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {(action: UIAlertAction!) -> Void in})
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true, completion: nil)
        categoryTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {

        categoryTableView.reloadData()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         categoryTableView.reloadData()
         categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "date", ascending: false)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        // Cellに値を設定する.
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name

        return cell
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let inputViewController:inputViewController = segue.destination as! inputViewController

            categoryTableView.reloadData()
            inputViewController.category = self.category
           
        }

    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        // データベースから削除する
        try! realm.write {
            self.realm.delete(self.categoryArray[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
            }
          }
        categoryTableView.reloadData()
        }

}

