//
//  CategoryViewController.swift
//  Todo List
//
//  Created by Burak Emre Toker on 22.02.2024.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar .placeholder = "Type Category to search.."
        
        return searchController
    }()
    
    let dataFilePath = FileManager
        .default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first?
        .appendingPathComponent("Items.plist")
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: K.rightBarButtonColor)
        print(dataFilePath!)
        loadItems()
    }
    
    //MARK: - SwipeTableVC Methods
    override func updateModel(at: IndexPath) {
        guard let category = categories?[at.row] else { return }
        
        do {
            try realm.write {
                realm.delete(category)
                print("category is deleted")
            }
        } catch {
            print(error.localizedDescription)
        }
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel!.text = categories?[indexPath.row].name ?? "No categories added yet."
        return cell
    }
    
    //MARK: - Table View Delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.categoryToTodoIdentifier, sender: self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        
        destinationVC.selectedCategory = categories?[indexPath.row]
    }
}

//MARK: - CoreData Methods

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
