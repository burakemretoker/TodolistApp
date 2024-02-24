//
//  Item.swift
//  Todo List
//
//  Created by Burak Emre Toker on 23.02.2024.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var isCheckmarked: Bool = false
    @objc dynamic var dateCreated = Date()
    
    // if you didn't understand why we used var instead of var, just change it to "let" and see in TodoListVC
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
