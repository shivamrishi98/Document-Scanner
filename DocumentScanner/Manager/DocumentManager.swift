//
//  DocumentManager.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 17/03/21.
//

import Foundation
import UIKit
import PDFKit

final class DocumentManager {
    
    public static let shared = DocumentManager()
    
    private init() { }
    
    
    public func openDocument(_ document:Document,from viewController:UIViewController) {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
            return
        }
        
        let docUrl = documentDirectory.appendingPathComponent(document.fileName)
        
        if FileManager.default.fileExists(atPath: docUrl.path)
        {
            let vc = PDFViewController(url: docUrl)
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.navigationItem.title = "PDF Viewer"
            viewController.present(UINavigationController(rootViewController: vc), animated: true)
        }
        
    }
    
}
