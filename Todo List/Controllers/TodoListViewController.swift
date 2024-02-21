//
//  ViewController.swift
//  Todo List
//
//  Created by Burak Emre Toker on 19.02.2024.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    private lazy var searchController: UISearchController = {
        let sController = UISearchController(searchResultsController: nil)
        sController.delegate = self
        sController.searchResultsUpdater = self
        sController.obscuresBackgroundDuringPresentation = false
        sController.searchBar.placeholder = "Type a keyword..."
        sController.searchBar.delegate = self
        return sController
    }()
    
    var itemArray = [Item]()
    
    let dataFilePath = FileManager
        .default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first?
        .appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        print(dataFilePath!)
        navigationItem.title = "Todoey"
        navigationItem.rightBarButtonItem?.tintColor = .white
        loadItems()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            if textField.text?.count != 0 {
                let item = Item(context: self.context)
                item.name = textField.text!
                item.isCheckmarked = false
                self.itemArray.append(item)
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
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        // ⭐️ the code below is equal to if statement its below.
        item.isCheckmarked = !item.isCheckmarked
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Data Manipulation

extension TodoListViewController {
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        self.tableView.reloadData()
        print("📁 DB saved.")
    }
    
    private func loadItems(for request: NSFetchRequest<Item> =
                           Item.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Encountered an error while trying to fetch data from CoreData as \"Error\": \(error.localizedDescription)")
        }
    }
    
}

//MARK: - SearchBar Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
    
}

extension TodoListViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count != 0 {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchController.searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            loadItems(for: request)
            
        } else {
            loadItems()
            
        }
    }
    
}
