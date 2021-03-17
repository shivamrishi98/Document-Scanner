//
//  ToggleView.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import UIKit

protocol ToggleViewDelegate:AnyObject {
    func toggleViewDidTapScanner(_ toggleView:ToggleView)
    func toggleViewDidTapImageToText(_ toggleView:ToggleView)
}

class ToggleView: UIView {

    enum State {
        case scanner
        case imageToText
        
    }
    
    var state: State = .scanner
    
    weak var delegate:ToggleViewDelegate?
    
    private let scannerButton:UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Scanner", for: .normal)
        return button
    }()
    
    private let imageToTextButton:UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("OCR", for: .normal)
        return button
    }()
    
    private let indicatorView:UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scannerButton)
        addSubview(imageToTextButton)
        addSubview(indicatorView)
        
        scannerButton.addTarget(self,
                                 action: #selector(didTapScanner),
                                 for: .touchUpInside)
        imageToTextButton.addTarget(self,
                                 action: #selector(didTapImageToText),
                                 for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func didTapScanner() {
        state = .scanner
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layoutIndicator()
        }
        delegate?.toggleViewDidTapScanner(self)
    }
    
    @objc private func didTapImageToText() {
        state = .imageToText
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layoutIndicator()
        }
        delegate?.toggleViewDidTapImageToText(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scannerButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        imageToTextButton.frame = CGRect(x: (scannerButton.frame.size.width+scannerButton.frame.origin.x), y: 0, width: 100, height: 40)
        layoutIndicator()
    }
    
    private func layoutIndicator() {
        
        switch state {
        case .scanner:
            
            indicatorView.frame = CGRect(x: 0,
                                         y: scannerButton.frame.size.height+scannerButton.frame.origin.y,
                                         width: 100,
                                         height: 3)
            
        case .imageToText:
            
            indicatorView.frame = CGRect(x: 100,
                                         y: imageToTextButton.frame.size.height+imageToTextButton.frame.origin.y,
                                         width: 100,
                                         height: 3)
            
        }
        
    }
    
    func update(for state:State) {
        self.state = state
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layoutIndicator()
        }
        
    }

}


