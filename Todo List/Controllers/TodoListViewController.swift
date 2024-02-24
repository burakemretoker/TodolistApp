//
//  ViewController.swift
//  Todo List
//
//  Created by Burak Emre Toker on 19.02.2024.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {

    let realm = try! Realm()
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    private lazy var searchController: UISearchController = {
        let sController = UISearchController(searchResultsController: nil)
        sController.delegate = self
        sController.searchResultsUpdater = self
        sController.obscuresBackgroundDuringPresentation = false
        sController.searchBar.placeholder = "Type a keyword..."
        sController.searchBar.delegate = self
        return sController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: K.rightBarButtonColor)
        tableView.rowHeight = 50
    }
    
    //MARK: - SwipeTableVC Methods
    
    override func updateModel(at: IndexPath) {
        guard let item = items?[at.row] else { return }
        
        do {
            try realm.write {
                realm.delete(item)
                print("item is deleted")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            if textField.text?.count != 0 {
                guard self.selectedCategory != nil else {
                    print("selectedCategory is founded by nil!")
                    return
                }
                // ⭐️ Important things are around here. Watch out, we did save our appendings in here.
                // check todolistVC saving.
                
                do {
                    try self.realm.write {
                        let item = Item()
                        item.name = textField.text!
                        self.selectedCategory!.items.append(item)
                        self.tableView.reloadData()
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }

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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item =  items?[indexPath.row]
        cell.textLabel?.text = item?.name ?? "No items added yet."
        
        // Ternarry Operation in Swift
        // ⭐️ ⭐️ value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item?.isCheckmarked == false ? .none : .checkmark
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
}

//MARK: - TableView Delegate

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = items?[indexPath.row] else { return }
        do {
            try realm.write {
                item.isCheckmarked = !item.isCheckmarked
                self.tableView.reloadData()
            }
        } catch {
            print("Encountered error in didSelectRowAt as Error: \(error.localizedDescription) ")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Data Manipulation

extension TodoListViewController {
    
    // See predicate argument in that function? We implemented it much more succint than Angela did.
    // But if the works becomes enormously hard, NSCompoundPredicate (The one Angela used) maybe is that much easy.
    private func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
}

//MARK: - SearchBar Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
    
}

extension TodoListViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text?.count != 0 {
            items = selectedCategory?.items.filter("name CONTAINS[cd] %@", searchController.searchBar.text!)
                .sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
    
}


//MARK: - SwipeTableVC Delegate


//extension TodoListViewController: SwipeTableViewCellDelegate {
//    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil }
//
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//            // handle action by updating model with deletion
//            do {
//                try self.realm.write {
//                    if let item = self.items?[indexPath.row] {
//                        self.realm.delete(item)
//                        action.fulfill(with: .delete)
//                        print("Ohh Item deleted.")
//                    }
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//            tableView.reloadData()
//            
//        }
//
//        // customize the action appearance
//        deleteAction.image = UIImage(systemName: "trash")
//
//        return [deleteAction]
//    }
//    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        return options
//    }
//
//
//}
