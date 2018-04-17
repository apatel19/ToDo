//
//  ViewController.swift
//  ToDo
//
//  Created by Apurva Patel on 4/10/18.
//  Copyright © 2018 Apurva Patel. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController{

    var todoItem : Results<Item>?
    
    let realm = try! Realm ()
    
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print (dataFilePath)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItem?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItem?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            
            cell.textLabel?.text = "No items added"
            
        }

        
        
        return cell
    }

   //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = todoItem?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch{
                print ("Error updating items \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items 
   
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new to item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
    
            if let currentCategoty = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategoty.items.append(newItem)
                    }
                } catch {
                    print ("Error saving data \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new item"
            textField = alertTextfield
        }
        
        alert.addAction(action)
    
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods

    
    func loadItems () {

        todoItem = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }


}

//MARK: - Search bar methods

extension TodoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItem = todoItem?.filter(NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }


        }
    }

}
