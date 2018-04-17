//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Apurva Patel on 4/15/18.
//  Copyright © 2018 Apurva Patel. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    
    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print (dataFilePath)
        
        loadCategory()
        
    }
    
    //MARK : Tableview Datasource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added yet"
        
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
    
    //MARK : Add new Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryField = UITextField ()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = categoryField.text!
          
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
