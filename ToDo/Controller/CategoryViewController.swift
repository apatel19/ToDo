//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Apurva Patel on 4/15/18.
//  Copyright © 2018 Apurva Patel. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print (dataFilePath)
        
        tableView.separatorStyle = .none
        
        loadCategory()
    }
    
    //MARK : Tableview Datasource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added yet"
        
        let colorString = categoryArray?[indexPath.row].color ?? "#FFFFFF"
        
        cell.backgroundColor = UIColor(hexString: colorString)
        
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: colorString)!, returnFlat: true)
        return cell
    }
    
    //MARK : Tableview Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
       
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        
        }
        
    }
    
    
    
    
    //MARK : Data Manupulation Method

    func save (category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print ("Error saving context \(error)")
        }
        tableView.reloadData()
        
    }
    
    func loadCategory (){

        categoryArray = realm.objects(Category.self)
        
        
        tableView.reloadData()
    }
    
    //MARK : Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let deleteCategory = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                     self.realm.delete(deleteCategory)
                }
                
            }catch {
                print ("Error deleting category \(error)")
            }
        }
    }
    
    //MARK : Add new Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryField = UITextField ()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = categoryField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            self.save(category : newCategory)
        }
        
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new category"
            categoryField = alertTextfield
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
