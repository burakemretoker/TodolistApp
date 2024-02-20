//
//  ViewController.swift
//  Todo List
//
//  Created by Burak Emre Toker on 19.02.2024.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    let dataFilePath = FileManager
        .default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first?
        .appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath!)
        // Do any additional setup after loading the view.
        navigationItem.title = "Todoey"
        navigationItem.rightBarButtonItem?.tintColor = .white
        loadItems()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            if let itemName = textField.text {
                self.itemArray.append(Item(name: itemName, isCheckmarked: false))
                self.saveItems()
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
        saveItems()
//        if item.isCheckmarked == false {
//            item.isCheckmarked = true
//        } else {
//            item.isCheckmarked = false
//        }
        
        print("2. \(item.name): \(item.isCheckmarked)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Data Manipulation

extension TodoListViewController {
    
    private func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print(error.localizedDescription)
        }
        
        self.tableView.reloadData()
        print("➕ Item added.")
    }
    
    private func loadItems() {
        //The code above will work as do catch code blocks.
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                let decodedItems = try decoder.decode([Item].self, from: data)
                itemArray = decodedItems
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
    }
}
