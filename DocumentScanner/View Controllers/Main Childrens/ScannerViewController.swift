//
//  ViewController.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 15/03/21.
//

import UIKit
import VisionKit
import Vision
import PDFKit


final class ScannerViewController: UIViewController {

    
    private var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    private var textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                         qos: .userInitiated,
                                                         attributes: [],
                                                         autoreleaseFrequency: .workItem)
    
    private let scanButton:UIButton = {
        let button = UIButton()
        button.setTitle("Scan Document", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        return  button
    }()
    
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scanner"
        view.backgroundColor = . systemBackground
        view.addSubview(scanButton)
        view.addSubview(imageView)
        scanButton.addTarget(self,
                             action: #selector(didTapScanButton),
                             for: .touchUpInside)
        
        
        
        //        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { request, error in
        //            guard let observations = request.results as? [VNRecognizedTextObservation] ,
        //                  error == nil  else {
        //                print(error)
        //                return
        //            }
        //            var detectedText = ""
        //
        //            for observation in observations {
        //                guard let topCandidate = observation.topCandidates(1).first else {
        //                    return
        //                }
        //                detectedText += topCandidate.string
        //                detectedText += "\n"
        //            }
        //
        //
        //        })
        
    }
    
    @objc private func didTapScanButton() {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        present(vc,animated: true)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: 0,
                                 y: view.safeAreaInsets.top,
                                 width: view.frame.size.width,
                                 height: view.frame.size.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-200)
        
        
        scanButton.frame = CGRect(x: 20,
                                  y: (imageView.frame.size.height+imageView.frame.origin.y)/2,
                                  width: view.frame.size.width-40,
                                  height: 50)
        
    }
    
    private func recognizeTextInImage(_ image:UIImage) {
        guard let cgImage = image.cgImage else {
            return
        }
        
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage,
                                                       options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
        
    }
    
    
}

extension ScannerViewController:VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        let pdfDocument = PDFDocument()
        
        for pageNumber in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            //            recognizeTextInImage(image)
            guard let pdfPage = PDFPage(image: image) else {
                return
            }
            pdfDocument.insert(pdfPage,
                               at: pageNumber)
        }
        
        
        controller.dismiss(animated: true, completion: { [weak self] in
            let alert = UIAlertController(title: "Save Document",
                                          message: "",
                                          preferredStyle: .alert)
            let date = Date()
            let defaultName = "scan_document_at_\(date)".replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: " ", with: "_")
            
            alert.addTextField { textfield in
                textfield.text = defaultName + ".pdf"
            }
            
            alert.addAction(UIAlertAction(
                                title: "Save",
                                style: .default,
                                handler: { _ in
                                    guard let textfield = alert.textFields?.first,
                                          let text = textfield.text,
                                          !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                                        return
                                    }

                                    RealmManager.shared.saveDocument(
                                        pdfDocument,
                                        model: DocumentViewModel(
                                            fileName: text,
                                            createdDate: date)) { [weak self] success in
                                        DispatchQueue.main.async {
                                            NotificationCenter.default.post(name: .documentAddedNotification,object: nil)
                                            self?.tabBarController?.selectedIndex = 1
                                        }
                                    }
                                    
                                }))
            
            alert.addAction(UIAlertAction(
                                title: "Cancel",
                                style: .cancel,
                                handler: nil))
            
            self?.present(alert, animated: true)
        })
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        
        let alert = UIAlertController(title: "Error",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .destructive,
                                      handler: nil))
        
        present(alert,
                animated: true,
                completion: {
                    controller.dismiss(animated: true, completion: nil)
                })
        
        
    }
    
}

