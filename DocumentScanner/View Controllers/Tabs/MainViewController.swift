//
//  MainViewController.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import UIKit

class MainViewController: UIViewController {

    private let scannerVC = ScannerViewController()
    private let imageToTextVC = ImageToTextViewController()
    
    private let toggleView = ToggleView()
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .blue
        return scrollView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = . systemBackground
        view.addSubview(scrollView)
        view.addSubview(toggleView)
        toggleView.delegate = self
        scrollView.delegate = self
        
        scrollView.contentSize = CGSize(width: view.frame.size.width*2,
                                        height: scrollView.frame.size.height)
        addChildren()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top+55,
            width: view.frame.size.width,
            height: view.frame.size.height-(view.safeAreaInsets.top-view.safeAreaInsets.bottom)-55)
        
        toggleView.frame = CGRect(x: 10,
                                  y: view.safeAreaInsets.top,
                                  width: 200,
                                  height: 55)
        
    }

    private func addChildren() {
        addChild(scannerVC)
        scrollView.addSubview(scannerVC.view)
        scannerVC.view.frame = CGRect(x: 0,
                                      y: 0,
                                      width: scrollView.frame.size.width,
                                      height: scrollView.frame.size.height)
        scannerVC.didMove(toParent: self)
        
        addChild(imageToTextVC)
        scrollView.addSubview(imageToTextVC.view)
        imageToTextVC.view.frame = CGRect(x: view.frame.size.width,
                                      y: 0,
                                      width: scrollView.frame.size.width,
                                      height: scrollView.frame.size.height)
        imageToTextVC.didMove(toParent: self)
    }
    
}

extension MainViewController:UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x >= (view.frame.size.width-100) {
            toggleView.update(for: .imageToText)
        } else {
            toggleView.update(for: .scanner)
        }
    }
}

extension MainViewController:ToggleViewDelegate {
    
    func toggleViewDidTapScanner(_ toggleView: ToggleView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func toggleViewDidTapImageToText(_ toggleView: ToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width, y: 0), animated: true)
    }
    
    
}
