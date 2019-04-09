//
//  ViewController.swift
//  Todo-CoreData
//
//  Created by Anofienam Isioma on 09/04/2019.
//  Copyright © 2019 com.chuck. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item1 = Item(title: "Go to Shop", done: false)
        let item2 = Item(title: "Buy Bread", done: false)
        let item3 = Item(title: "Buy Coffee", done: false)
        itemArray = [item1, item2, item3]
        
        if let defaultsArr = UserDefaults.standard.array(forKey: "TodolistArray") as? [Item]{
            itemArray = defaultsArr
        }
        
    }
    
    //MARK - Rable view datasource methods
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        tableView.deselectRow(at: indexPath, animated: true)
    
        tableView.reloadData()
        
        //MARK- Code works but the cells with checkmarks are reused... below
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        }else{
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
    }
        
    

    
    //MARK- Add New Items
    @IBAction func AddNewTodo(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Add new Todo", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //when user clicks add item button
            let item = Item(title: textfield.text!, done: false)
            self.itemArray.append(item)
            self.defaults.set(self.itemArray, forKey: "TodolistArray")
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textfield = alertTextField
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}

