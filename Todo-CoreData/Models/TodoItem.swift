//
//  TodoItem.swift
//  Todo-CoreData
//
//  Created by Anofienam Isioma on 17/04/2019.
//  Copyright © 2019 com.chuck. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var parentCategory = LinkingObjects(fromType: TodoCategory.self, property: "items")
}
