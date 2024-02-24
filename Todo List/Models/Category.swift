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
    let items = List<Item>()
}
