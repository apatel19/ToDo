//
//  ViewController.swift
//  ToDo
//
//  Created by Apurva Patel on 4/10/18.
//  Copyright © 2018 Apurva Patel. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{

    var todoItem : Results<Item>?
    
    let realm = try! Realm ()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        
        
        guard let colorHex = selectedCategory?.color else { fatalError()}
            
        
        updateNavbar(withHexCode: colorHex)
        
        
    }
    

//    override func viewWillDisappear(_ animated: Bool) {
//        updateNavbar(withHexCode: "1D9BF6")
//    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        updateNavbar(withHexCode: "1D9BF6")
    }
    
    //MARK - Nav bar set up
    
    func updateNavbar (withHexCode colorHex : String){
        
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Controller doest not exit.") }
        
        guard let navBarColor = UIColor(hexString: colorHex) else { fatalError() }
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItem?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItem?[indexPath.row] {
            
            cell.textLabel?.text = item.title
        
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(CGFloat(indexPath.row) / CGFloat(todoItem!.count))) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            
            
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

    //MARK - Swipe Item deletation
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let deleteData = self.todoItem?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(deleteData)
                }
            }catch {
                    print ("Error deleting data \(error)")
                }
            }
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
