//
//  CategoryViewController.swift
//  Todo-CoreData
//
//  Created by Anofienam Isioma on 10/04/2019.
//  Copyright © 2019 com.chuck. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController{

    let realm = try! Realm()
    var categories : Results<TodoCategory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.rowHeight = 80
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let category = categories?[indexPath.row]
        
        cell.textLabel?.text = category?.name ?? "No Categories Added Yet"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goToItems", sender: self)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "Enter the name of the category and hit the button", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = TodoCategory()
            newCategory.name = textField.text!
            newCategory.dateCreated = Date()
//            self.categories.append(newCategory)
            self.saveCategory(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Add new Category"
            textField = alertTextField
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveCategory(category: TodoCategory){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving Category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        categories = realm.objects(TodoCategory.self)
       
        tableView.reloadData()
    }
}

//MARK - SWipe Cell delegate Methods
extension CategoryViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else{ return nil }
        
        let editAction = SwipeAction(style: .default, title: "Rename") { (action, indexPath) in
     
            var textfield = UITextField()
            let rename = UIAlertController(title: "Rename Category", message: "", preferredStyle: .alert)
            
            let renameAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                
                if let category = self.categories?[indexPath.row]{
                    do{
                        try self.realm.write {
                            category.name = textfield.text!
                        }
                    }catch{
                        print("Error renaming item, \(error)")
                    }
                }
                
                tableView.reloadData()

            })
            
            rename.addTextField(configurationHandler: { (field) in
                field.placeholder = "Enter new name"
                textfield = field
            })
            
            rename.addAction(renameAction)
            self.present(rename, animated: true, completion: nil)
            
        }
        
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            if let category = self.categories?[indexPath.row]{
                do{
                    try self.realm.write {
                        self.realm.delete(category.items)
                        self.realm.delete(category)
                    }
                    
                }catch{
                    print("\(error)")
                }
//                tableView.reloadData()
            }
            
        }
        
        deleteAction.image = UIImage(named: "deleteIcon")
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    
}
