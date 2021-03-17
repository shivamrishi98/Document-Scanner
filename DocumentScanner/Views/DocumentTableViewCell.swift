//
//  DocumentTableViewCell.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import UIKit

final class DocumentTableViewCell: UITableViewCell {
    
    static let identifier = "DocumentTableViewCell"
    
    private let fileNameLabel:UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = . systemFont(ofSize: 14,
                                  weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    private let createdDateLabel:UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = . systemFont(ofSize: 12,
                                  weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(fileNameLabel)
        addSubview(createdDateLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fileNameLabel.frame = CGRect(x: 10,
                                     y: (frame.origin.x) + 10,
                                     width: frame.size.width-20,
                                     height: 20)
        
        createdDateLabel.frame = CGRect(x: 15,
                                        y: (fileNameLabel.frame.size.height+fileNameLabel.frame.origin.y) + 5,
                                        width: frame.size.width-30,
                                        height: 20)
        
    }
    
    func configure(with viewModel:DocumentViewModel) {
        fileNameLabel.text = viewModel.fileName
        let dateString = DateFormatter.dateFormatter.string(from: viewModel.createdDate)
        createdDateLabel.text = dateString
    }
    
}
