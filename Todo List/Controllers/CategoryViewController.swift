//
//  CategoryViewController.swift
//  Todo List
//
//  Created by Burak Emre Toker on 22.02.2024.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar .placeholder = "Type Category to search.."
        
        return searchController
    }()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: K.backgroundColor)
        tableViewMethods()
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBarMethods()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        let alertController = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            if categoryTextField.text!.count != 0 {
                let category = Category()
                category.name = categoryTextField.text!
                self.save(category: category)
            }
            
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Add new category.."
            categoryTextField = textField
            print(textField.text!)
        }
        
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    private func tableViewMethods() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 20
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(named: K.seperatorColorTV)
        tableView.tintColor = UIColor(named: K.seperatorColorTV)
        
    }
    
    private func navBarMethods() {
        guard let navBar = navigationController?.navigationBar else { fatalError("navigationBar is founded to be nil.")}
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.backgroundColor = UIColor(named: K.backgroundColor)
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navBar.prefersLargeTitles = true
    }
    
    private func navItemMethods() {
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: K.rightBarButtonColor)
    }
    
}

// MARK: - Table View Data Source

extension CategoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellIdentifier, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel!.text = categories?[indexPath.row].name ?? "No categories added yet."
        cell.backgroundColor = UIColor(named: K.tableViewColor)
        cell.alpha = 0.5
        return cell
    }
}

//MARK: - Table View Delegate

extension CategoryViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.categoryToTodoIdentifier, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        
        destinationVC.selectedCategory = categories?[indexPath.row]
    }
}

//MARK: - Realm Data Manipulation

extension CategoryViewController {
    
    private func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
            tableView.reloadData()
        } catch {
            print("Encountered an error when try to save \"category context\", Error: \(error.localizedDescription)")
        }
    }
    
    private func loadItems() {
        categories = realm.objects(Category.self).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
}

//MARK: - Search Controller and Search Bar
extension CategoryViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count != 0 {
            let searchText = searchController.searchBar.text!
            categories = categories?.filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
    
}

extension CategoryViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            guard let category = self.categories?[indexPath.row] else { return }
            do {
                try self.realm.write {
                    self.realm.delete(category)
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

