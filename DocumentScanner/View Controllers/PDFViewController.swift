//
//  PDFViewController.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import UIKit
import PDFKit

final class PDFViewController: UIViewController {

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
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(didTapCloseButton))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.down.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(didTapSaveToPhotoLibraryButton))
        
    }
    
    @objc private func didTapSaveToPhotoLibraryButton() {
        
        guard let images = drawPDFfromURL(url: docUrl) else {
            return
        }

        for index in 0..<images.count {
            UIImageWriteToSavedPhotosAlbum(images[index],
                                           self,
                                           #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                           nil)
        }
    }
    
    
    func drawPDFfromURL(url: URL) -> [UIImage]? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        var image = [UIImage]()
        for pageNumber in 1...document.numberOfPages {
            guard let page = document.page(at: pageNumber) else { return nil }
            
            let pageRect = page.getBoxRect(.mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)
                
                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                ctx.cgContext.drawPDFPage(page)
            }
            image.append(img)
        }
        
        return image
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        guard error == nil else {
            let alert = UIAlertController(title: "Error",
                                          message: error?.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .cancel,
                                          handler: nil))
            present(alert,
                    animated: true)
            return
        }
        
        let alert = UIAlertController(title: "Success",
                                      message: "Your pdf has been saved to photos",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        present(alert,
                animated: true)
        
    }
    
    
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pdfView.frame = CGRect(x: 10,
                               y: 10,
                               width: view.frame.size.width-20,
                               height: view.frame.size.height-20)
        
        
    }

}
