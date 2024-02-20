//
//  ViewController.swift
//  Todo List
//
//  Created by Burak Emre Toker on 19.02.2024.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item(name: "Messi", isCheckmarked: false),
                     Item(name: "Mesasi", isCheckmarked: false),
                     Item(name: "Mesdssi", isCheckmarked: false),
                     Item(name: "Mesdffsi", isCheckmarked: false),
                     Item(name: "Messddsi", isCheckmarked: false),
                     Item(name: "Messasdfi", isCheckmarked: false),
                     Item(name: "Mesadsfsi", isCheckmarked: false),
                     Item(name: "Messdafsi", isCheckmarked: false),
                     Item(name: "Mesasdfsi", isCheckmarked: false),
                     Item(name: "Mesasdfsi", isCheckmarked: false),
                     Item(name: "Mesadsfsi", isCheckmarked: false),
                     Item(name: "Mesdafssi", isCheckmarked: false),
    ]
    

    
    var checkmarkedArray: [String: Any] = [:]
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.title = "Todoey"
        navigationItem.rightBarButtonItem?.tintColor = .white
        
//        if let items = defaults.array(forKey: "TodoListArray") as? [String] {
//            itemArray = items
//        }
        
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
            print("Hi")
        }
        
        
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            if let itemName = textField.text {
                self.itemArray.append(Item(name: itemName, isCheckmarked: false))
                self.defaults.set(self.itemArray, forKey: "TodoListArray")
                self.tableView.reloadData()
                print("➕ Item added.")
            }
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new Todoey."
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
}

//MARK: - TableView Data Source
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell", for: indexPath)
        let item =  itemArray[indexPath.row]
        cell.textLabel?.text = item.name
        
        // Ternarry Operation in Swift
        // ⭐️ ⭐️ value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.isCheckmarked == false ? .none : .checkmark
        // The code below' equal form is the line just above.
        
//        if item.isCheckmarked == false {
//            cell.accessoryType = .none
//        } else {
//            cell.accessoryType = .checkmark
//        }
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
}

//MARK: - TableView Delegate

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item =  itemArray[indexPath.row]
        print("1. \(item.name): \(item.isCheckmarked)")
        
        // ⭐️ the code below is equal to if statement its below.
        item.isCheckmarked = !item.isCheckmarked
        
//        if item.isCheckmarked == false {
//            item.isCheckmarked = true
//        } else {
//            item.isCheckmarked = false
//        }
        
        print("2. \(item.name): \(item.isCheckmarked)")
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)


        
        
    }
    
  
}
