//
//  Document.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 17/03/21.
//

import Foundation
import RealmSwift

class Document:Object {
    @objc dynamic var id = ""
    @objc dynamic var fileName = ""
    @objc dynamic var createdDate:Date = Date()
}
