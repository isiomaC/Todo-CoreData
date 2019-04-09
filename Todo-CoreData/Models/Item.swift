//
//  Item.swift
//  Todo-CoreData
//
//  Created by Anofienam Isioma on 09/04/2019.
//  Copyright © 2019 com.chuck. All rights reserved.
//

import Foundation

class Item {
    var title = ""
    var done = false
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}
