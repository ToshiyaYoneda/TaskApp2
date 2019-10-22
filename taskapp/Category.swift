//
//  Category.swift
//  taskapp
//
//  Created by ToshiyaYoneda on 2019/10/07.
//  Copyright © 2019 ToshiyaYoneda. All rights reserved.
//

import RealmSwift

class Category: Object {
    

    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    @objc dynamic var name = ""
    
    @objc dynamic var date = Date()

    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}






