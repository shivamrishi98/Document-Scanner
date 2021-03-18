//
//  ImageToTextViewController.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import UIKit
import VisionKit
import Vision
import PDFKit

final class ImageToTextViewController: UIViewController {

    private var textRecognitionRequest:VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest(completionHandler: nil)
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        return request
    }()
    
    private var textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                         qos: .userInitiated,
                                                         attributes: [],
                                                         autoreleaseFrequency: .workItem)
    private var detectedText = ""
    
    private let textView:UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 12
        textView.isEditable = false
        return textView
    }()
    
    private let scanButton:UIButton = {
        let button = UIButton()
        button.setTitle("Scan", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = . systemOrange
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let copyButton:UIButton = {
        let button = UIButton()
        button.setTitle("Copy Text", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        view.addSubview(scanButton)
        view.addSubview(copyButton)
        scanButton.addTarget(self,
                             action: #selector(didTapScanButton),
                             for: .touchUpInside)
        copyButton.addTarget(self,
                             action: #selector(didTapCopyButton),
                             for: .touchUpInside)
        
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] ,
                  error == nil  else {
                print(error?.localizedDescription)
                return
            }
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    return
                }
                self?.detectedText += topCandidate.string
                self?.detectedText += "\n"
            }
            
            DispatchQueue.main.async {
                self?.textView.text = self?.detectedText
            }
        })
        
    }
    
    @objc private func didTapScanButton() {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        present(vc,animated: true)
    }
    
    @objc private func didTapCopyButton() {
        guard let text = textView.text else {
            return
        }
        
        UIPasteboard.general.string = text
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.frame = CGRect(x: 20,
                                y: 20,
                                width: view.frame.size.width-40,
                                height: view.frame.size.height*0.60)
        
        copyButton.frame = CGRect(x: (view.frame.size.width)-100,
                                  y: (textView.frame.size.height + textView.frame.origin.y) + 5,
                                  width: 100,
                                  height: 20)
        
        scanButton.frame = CGRect(x: 20,
                                  y: (copyButton.frame.size.height + copyButton.frame.origin.y) + 10,
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

extension ImageToTextViewController:VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        detectedText = ""
        copyButton.isHidden = false
        let pdfDocument = PDFDocument()
        
        for pageNumber in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            recognizeTextInImage(image)
            guard let pdfPage = PDFPage(image: image) else {
                return
            }
            pdfDocument.insert(pdfPage,
                               at: pageNumber)
        }
        
        controller.dismiss(animated: true, completion: nil)
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

