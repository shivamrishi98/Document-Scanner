//
//  DocumentsViewController.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import UIKit
import RealmSwift

class DocumentsViewController: UIViewController {

    private let realm = try! Realm()
    
    private var viewModels = [DocumentViewModel]()
    private var documents = [Document]()
    
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
    
    private var observer:NSObjectProtocol?
    
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
        let documents = realm.objects(Document.self)
        self.documents = documents.compactMap({$0})
        if !documents.isEmpty {
            tableView.isHidden = false
            noDocumentsLabel.isHidden = true
            for document in documents {
                self.viewModels.append(DocumentViewModel(fileName: document.fileName,
                                                         createdDate: document.createdDate))
            }
            tableView.reloadData()
        } else {
            tableView.isHidden = true
            noDocumentsLabel.isHidden = false
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
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
            return
        }
        
        let document = documents[indexPath.row]
        let docUrl = documentDirectory.appendingPathComponent(document.fileName)

        if FileManager.default.fileExists(atPath: docUrl.path)
           {
            let vc = PDFViewController(url: docUrl)
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.navigationItem.title = "PDF Viewer"
            present(UINavigationController(rootViewController: vc), animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let document = documents[indexPath.row]
            
            tableView.beginUpdates()
           let viewModel = viewModels.remove(at: indexPath.row)
           let deletedDocument = documents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            do {
                realm.beginWrite()
                realm.delete(document)
                try realm.commitWrite()
                
            } catch {
                print(error.localizedDescription)
                viewModels.insert(viewModel, at: indexPath.row)
                documents.insert(deletedDocument, at: indexPath.row)
                tableView.insertRows(at: [indexPath],
                                     with: .left)
            }
            self.fetchData()
            tableView.endUpdates()
        }
        
    }
    
}
