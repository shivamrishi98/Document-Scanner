//
//  RealmManager.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 17/03/21.
//

import UIKit
import RealmSwift
import PDFKit

final class RealmManager {
    
    public static let shared = RealmManager()
    
    private let realm = try! Realm()
    
    
    private init() { }
    
    public func saveDocument(_ pdfDocument:PDFDocument,model:DocumentViewModel,completion:@escaping (Bool)->Void) {
        
        guard let documentData = pdfDocument.dataRepresentation(),
              let documentDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask).first else {
            return
        }
        
        let docUrl = documentDirectory.appendingPathComponent(model.fileName)
        
        let object = Document()
        object.id = UUID().uuidString
        object.fileName = model.fileName
        object.createdDate = model.createdDate
        do {
            try documentData.write(to: docUrl)
            realm.beginWrite()
            realm.add(object)
            try realm.commitWrite()
            completion(true)

        }
        catch {
            print(error.localizedDescription)
            completion(false)
        }
        
    }
    
    
   public func fetchDocuments(completion: @escaping (Results<Document>)->Void) {
        let documents = realm.objects(Document.self)
        completion(documents)
    }
        
    public func deleteDocument(_ document:Document,completion:@escaping (Bool)->Void) {
        
        do {
            realm.beginWrite()
            realm.delete(document)
            try realm.commitWrite()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
        
        
    }
    
}

