//
//  MPasteItem.swift
//  YPaste
//
//  Created by 虚幻 on 2020/11/1.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Foundation
import RealmSwift

// Define your models like regular Swift classes
class MPasteItem: Object {
    @objc dynamic var value = ""
    @objc dynamic var type = "text"
    @objc dynamic var created_at = Date()
    @objc dynamic var updated_at = Date()
    @objc dynamic var favorite = false
}
