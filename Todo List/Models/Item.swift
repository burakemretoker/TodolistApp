//
//  Item.swift
//  Todo List
//
//  Created by Burak Emre Toker on 20.02.2024.
//

import Foundation
import UIKit

class Item: Codable {
    var name: String
    var isCheckmarked: Bool
    
    init(name: String, isCheckmarked: Bool) {
        self.name = name
        self.isCheckmarked = isCheckmarked
    }
}

// ‼️

//class Item {
//    var name: String
//    var isCheckmarked: UITableViewCell.AccessoryType
//    
//    init(name: String, isCheckmarked: UITableViewCell.AccessoryType) {
//        self.name = name
//        self.isCheckmarked = isCheckmarked
//    }
//}


//    var itemArray = [Item(name: "Messi", isCheckmarked: .none),
//                     Item(name: "Mesasi", isCheckmarked: .none),
//                     Item(name: "Mesdssi", isCheckmarked: .none),
//                     Item(name: "Mesdffsi", isCheckmarked: .none),
//                     Item(name: "Messddsi", isCheckmarked: .none),
//                     Item(name: "Messasdfi", isCheckmarked: .none),
//                     Item(name: "Mesadsfsi", isCheckmarked: .none),
//                     Item(name: "Messdafsi", isCheckmarked: .none),
//                     Item(name: "Mesasdfsi", isCheckmarked: .none),
//                     Item(name: "Mesasdfsi", isCheckmarked: .none),
//                     Item(name: "Mesadsfsi", isCheckmarked: .none),
//                     Item(name: "Mesdafssi", isCheckmarked: .none),
//    ]
