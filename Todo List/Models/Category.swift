//
//  Category.swift
//  Todo List
//
//  Created by Burak Emre Toker on 23.02.2024.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var dateCreated: Date = Date()
    let items = List<Item>()
}
