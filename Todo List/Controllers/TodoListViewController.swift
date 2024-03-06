//
//  ViewController.swift
//  Todo List
//
//  Created by Burak Emre Toker on 19.02.2024.
//

import UIKit
import RealmSwift
import SwipeCellKit

class TodoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
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
        view.backgroundColor = UIColor(named: K.backgroundColor)
        navBarMethods()
        tableViewMethods()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItemMethods()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
           if parent == nil
           {
               print("This VC is 'will' be popped. i.e. the back button was pressed.")
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
    
    private func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
    }
    
    private func navBarMethods() {
        guard (navigationController?.navigationBar) != nil else { fatalError("Encountered an error trying to initialize navBar in TodoVC")}
        navigationController?.navigationBar.isTranslucent = true
        guard let navBar = navigationController?.navigationBar else { fatalError("navigationBar is founded to be nil.")}
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.backgroundColor = UIColor(named: K.backgroundColor)
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navBar.prefersLargeTitles = true
        title = selectedCategory!.name
    }
    
    private func navItemMethods() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: K.rightBarButtonColor)
    }
    
    private func tableViewMethods() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.layer.cornerRadius = 20
        tableView.separatorColor = UIColor(named: K.seperatorColorTV)
        tableView.tintColor = UIColor(named: K.seperatorColorTV)
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
    }
    
}

//MARK: - TableView Data Source
extension TodoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCellIdentifier, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let item =  items?[indexPath.row]
        cell.textLabel?.text = item?.name ?? "No items added yet."
        
        // Ternarry Operation in Swift
        // ⭐️ ⭐️ value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item?.isCheckmarked == false ? .none : .checkmark
        cell.backgroundColor = UIColor(named: K.tableViewColor)
        cell.alpha = 0.5
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
}

//MARK: - TableView Delegate

extension TodoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

//MARK: - SearchBar Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()
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

extension TodoListViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            guard let item = self.selectedCategory?.items[indexPath.row] else { return }
            do {
                try self.realm.write {
                    self.realm.delete(item)
                    print("category is deleted")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}
