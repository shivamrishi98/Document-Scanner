//
//  PDFViewController.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {

    private let pdfView:PDFView = {
        let view = PDFView()
        view.autoScales = true
        view.displaysAsBook = true
        return view
    }()
    
    private let docUrl:URL
    
    init(url:URL) {
        docUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(pdfView)
        let document = PDFDocument(url: docUrl)
        pdfView.document = document
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pdfView.frame = CGRect(x: 10,
                               y: 10,
                               width: view.frame.size.width-20,
                               height: view.frame.size.height-20)
        
        
    }

}
