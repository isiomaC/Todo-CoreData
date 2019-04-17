//
//  SwipeTableViewController.swift
//  Todo-CoreData
//
//  Created by Anofienam Isioma on 17/04/2019.
//  Copyright © 2019 com.chuck. All rights reserved.
//

import Foundation
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //Table View DataSource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else{ return nil }
        
        let editAction = SwipeAction(style: .default, title: "Rename") { (action, indexPath) in
            
            var textfield = UITextField()
            let rename = UIAlertController(title: "Rename Category", message: "", preferredStyle: .alert)
            
            let renameAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                
                self.updateModelWithValue(at: indexPath, textField: textfield)
                
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
            
            self.updateModel(at: indexPath)
            
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
    
    func updateModel(at indexPath: IndexPath){
        print("\(indexPath)")
    }
    
    func updateModelWithValue(at indexPath: IndexPath, textField field: UITextField?){
        print("\(indexPath) ------------ \(String(describing: field))")
    }
    
}
