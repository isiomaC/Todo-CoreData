//
//  TodoCategory.swift
//  Todo-CoreData
//
//  Created by Anofienam Isioma on 17/04/2019.
//  Copyright © 2019 com.chuck. All rights reserved.
//

import Foundation
import RealmSwift

class TodoCategory: Object{
 
    @objc dynamic var name: String = ""
    let items = List<TodoItem>()
}
