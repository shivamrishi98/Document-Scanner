//
//  DocumentsViewController.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import UIKit

final class DocumentsViewController: UIViewController {

    private var viewModels = [DocumentViewModel]()
    private var documents = [Document]()
    private var observer:NSObjectProtocol?
    
    private let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(DocumentTableViewCell.self,
                           forCellReuseIdentifier: DocumentTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    private let noDocumentsLabel:UILabel = {
        let label = UILabel()
        label.text = "No Documents"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(noDocumentsLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        observer = NotificationCenter.default.addObserver(
            forName: .documentAddedNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.fetchData()
            })
        
        fetchData()
        
        
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
        noDocumentsLabel.frame = CGRect(x: 0,
                                        y: (view.frame.size.height)/2,
                                        width: view.frame.size.width,
                                        height: 50)
    }
    
    private func fetchData() {
        viewModels.removeAll()
        
        RealmManager.shared.fetchDocuments { [weak self] documents in
            self?.documents = documents.compactMap({$0})
            
            DispatchQueue.main.async {
                if !documents.isEmpty {
                    self?.tableView.isHidden = false
                    self?.noDocumentsLabel.isHidden = true
                    for document in documents {
                        self?.viewModels.append(DocumentViewModel(fileName: document.fileName,
                                                                  createdDate: document.createdDate))
                    }
                    self?.tableView.reloadData()
                } else {
                    self?.tableView.isHidden = true
                    self?.noDocumentsLabel.isHidden = false
                }
            }
        }
        
        
    }
    
    
}

extension DocumentsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DocumentTableViewCell.identifier,
                                                      for: indexPath) as? DocumentTableViewCell else {
        return UITableViewCell()
       }
        let viewModel = viewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let document = documents[indexPath.row]
        DocumentManager.shared.openDocument(document, from: self)
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let document = documents[indexPath.row]
            let viewModel = viewModels[indexPath.row]
   
            RealmManager.shared.deleteDocument(document) { [weak self] success in

                if success {
                    self?.viewModels.remove(at: indexPath.row)
                    self?.documents.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .left)

                } else {
                    self?.viewModels.insert(viewModel, at: indexPath.row)
                    self?.documents.insert(document, at: indexPath.row)
                    self?.tableView.insertRows(at: [indexPath],
                                               with: .left)
                }
                self?.fetchData()
                tableView.reloadData()
     
            }
       
            
        }
        
    }
    
}
