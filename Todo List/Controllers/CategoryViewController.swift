//
//  CategoryViewController.swift
//  Todo List
//
//  Created by Burak Emre Toker on 22.02.2024.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
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

    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    var categoryArray = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem?.tintColor = .white
        print(dataFilePath!)
        loadItems()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        let alertController = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            if categoryTextField.text!.count != 0 {
                let category = Category(context: self.context)
                category.name = categoryTextField.text!
                self.categoryArray.append(category)
                self.saveCategory()
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
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellIdentifier, for: indexPath)
        cell.textLabel!.text = categoryArray[indexPath.row].name
        return cell
    }
    
    //MARK: - Table View Delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.categoryToTodoIdentifier, sender: self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        
        destinationVC.selectedCategory = categoryArray[indexPath.row]
    }
}

//MARK: - CoreData Methods

extension CategoryViewController {
    
    private func saveCategory() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Encountered an error when try to save \"category context\", Error: \(error.localizedDescription)")
        }
    }
    
    private func loadItems(with reqeust: NSFetchRequest<Category>
                           = Category.fetchRequest())
    {
        if let categories = try? context.fetch(reqeust) {
            categoryArray = categories
            tableView.reloadData()
        } else {
            print("Encountered an error when try to load \"category context\".")
        }
        
    }
    
}

//MARK: - Search Controller and Search Bar
extension CategoryViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.loadItems()
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            loadItems(with: request)
        }
    }
    
}
