//
//  Category.swift
//  ToDo
//
//  Created by Apurva Patel on 4/16/18.
//  Copyright © 2018 Apurva Patel. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    let items = List<Item>()
    
}
