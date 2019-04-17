//
//  ViewController.swift
//  Todo-CoreData
//
//  Created by Anofienam Isioma on 09/04/2019.
//  Copyright © 2019 com.chuck. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    //MARK - Context gotten from persistent container which is na SQLit for Coredata
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath)

    }
    
    //MARK - Table view datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done == true ?  .checkmark :  .none

        return cell
        
    }
    
    //MARK - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            //Delete Value from core Data
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveItems()
        }
        
        let edit = UITableViewRowAction(style: .default, title: "Rename") { (action, indexPath) in
            
            var textfield = UITextField()
            let rename = UIAlertController(title: "Rename TODO Item", message: "", preferredStyle: .alert)
            
            let renameAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                print(self.itemArray[indexPath.row])
                self.itemArray[indexPath.row].setValue(textfield.text, forKey: "title")
                print(self.itemArray[indexPath.row])
                self.saveItems()
            })
            
            rename.addTextField(configurationHandler: { (field) in
                field.placeholder = "Rename Item"
                textfield = field
            })
            
            rename.addAction(renameAction)
            self.present(rename, animated: true, completion: nil)

        }
        
        edit.backgroundColor = .lightGray

        return [delete, edit]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        saveItems()
        
    }
    
    //MARK - Add New Items
    @IBAction func AddNewTodo(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Add new Todo", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //when user clicks add item button on the alert controller
            
            let item = Item(context: self.context)
            item.title = textfield.text
            item.done = false
            item.parentCategory = self.selectedCategory
            self.itemArray.append(item)
            
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textfield = alertTextField
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do{
            try context.save()
        }catch{
            print("Error saving the data: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate? = nil) {
        
        //Query Based on the entitys parent name
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
//        let fetchReq = NSFetchRequest<Item>(entityName: "Item")
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error retrieving requests: \(error)")
        }
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
             let request: NSFetchRequest<Item> = Item.fetchRequest()
        
             request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
             request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
             loadItems(with: request, predicate: request.predicate)
        }
    }
}
