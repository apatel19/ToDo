//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Apurva Patel on 4/15/18.
//  Copyright © 2018 Apurva Patel. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category] ()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print (dataFilePath)
        
        loadCategory()
        
    }
    
    //MARK : Tableview Datasource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    //MARK : Tableview Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
       
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categoryArray[indexPath.row]
            
        }
        
    }
    
    
    
    //MARK : Data Manupulation Method

    
    func saveCategory () {
        
        do {
            try context.save()
        } catch {
            print ("Error saving context \(error)")
        }
        tableView.reloadData()
        
    }
    
    func loadCategory (with request: NSFetchRequest<Category> = Category.fetchRequest()){
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print ("Error fatching request \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK : Add new Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryField = UITextField ()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context : self.context)
            newCategory.name = categoryField.text!
            self.categoryArray.append(newCategory)
          
            self.saveCategory()
        }
        
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new category"
            categoryField = alertTextfield
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
