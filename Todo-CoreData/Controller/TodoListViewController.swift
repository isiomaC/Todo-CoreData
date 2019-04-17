//
//  ViewController.swift
//  Todo-CoreData
//
//  Created by Anofienam Isioma on 09/04/2019.
//  Copyright © 2019 com.chuck. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class TodoListViewController: UITableViewController {

    var todoItems : Results<TodoItem>?
    let realm = try! Realm()
    var selectedCategory: TodoCategory? {
        didSet{
            loadItems()
        }
    }
    
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // core data file path
        print(dataFilePath)

    }
    
    //MARK - Table view datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done == true ?  .checkmark :  .none

        }else{
            cell.textLabel?.text = "No item added"
        }
        
        
        return cell
        
    }
    
    //MARK - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            //Delete Values from realm database....
            if let item = self.todoItems?[indexPath.row]{
                do{
                    try self.realm.write {
                        self.realm.delete(item)
                    }
                    
                }catch{
                    print("error saving files\(error)")
                }
                
            }
            tableView.reloadData()
            
            //Delete Value from core Data
//            self.context.delete(self.todoItems?[indexPath.row])
//            self.todoItems?.remove(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .fade)
//            self.saveItems()
        }
        
        let edit = UITableViewRowAction(style: .default, title: "Rename") { (action, indexPath) in
            
            var textfield = UITextField()
            let rename = UIAlertController(title: "Rename TODO Item", message: "", preferredStyle: .alert)
            
            let renameAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                
                //Edit realm items
                if let item = self.todoItems?[indexPath.row]{
                    do{
                        try self.realm.write {
                            item.dateCreated = Date()
                            item.title = textfield.text!
                        }
                    }catch{
                        print("Error renaming item, \(error)")
                    }
                }
                
                tableView.reloadData()
                
                //Edit CoreData Items
//                print(self.todoItems[indexPath.row])
//                self.todoItems[indexPath.row].setValue(textfield.text, forKey: "title")
//                print(self.todoItems[indexPath.row])
//                self.saveItems()
            })
            
            rename.addTextField(configurationHandler: { (field) in
                
//                let selectedTitle = self.todoItems?[indexPath.row].title
//                let placeholderText = self.realm.objects(TodoItem.self).filter("title == %@", selectedTitle!)
                
                field.placeholder = "Enter new name"
                textfield = field
            })
            
            rename.addAction(renameAction)
            self.present(rename, animated: true, completion: nil)
        }
        
        edit.backgroundColor = .lightGray

        return [delete, edit]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error saving file\(error)")
            }
           
        }
        tableView.reloadData()
        
    }
    
    //MARK - Add New Items
    @IBAction func AddNewTodo(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Add new Todo", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //when user clicks add item button on the alert controller
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let item = TodoItem()
                        item.title = textfield.text!
                        item.dateCreated = Date()
                        currentCategory.items.append(item)
                    }
                }catch{
                    print("error saving files\(error)")
                }
            }
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textfield = alertTextField
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(item: TodoItem) {
        do{
           
            try realm.write {
                realm.add(item)
            }
        }catch{
            print("Error saving the data: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
}


//Mark - Search Bar methods
extension TodoListViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }else{
            
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
            
        }
    }
}
