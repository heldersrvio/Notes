//
//  ViewController.swift
//  Notes
//
//  Created by Helder on 28/08/20.
//  Copyright © 2020 Helder de Melo Sérvio Filho. All rights reserved.
//

import UIKit

class FoldersViewController: UITableViewController {
    var newFolderAlert: UIAlertController?
    var folderNames: [String] = [] {
        didSet {
            saveInfo()
        }
    }
    var editingMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if let bgImage = UIImage(named: "background.png") {
            view.backgroundColor = UIColor(patternImage: bgImage)
            navigationController?.toolbar.barTintColor = UIColor(patternImage: bgImage)
        }
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.toolbar.layer.borderWidth = 0
        setToolbarItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "New Folder", style: .plain, target: self, action: #selector(addNewFolder))], animated: false)
        toolbarItems?.forEach{$0.tintColor = UIColor(red: 0.88, green: 0.67, blue: 0, alpha: 1) }
        
        navigationItem.title = "Folders"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(red: 0.88, green: 0.67, blue: 0, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.88, green: 0.67, blue: 0, alpha: 1)
        
        tableView.tableFooterView = UIView()
        
        let ud = UserDefaults()
        folderNames = ud.stringArray(forKey: "folders") ?? []
        
    }
    
    @objc func edit() {
        editingMode = !editingMode
        if editingMode {
            navigationItem.rightBarButtonItem?.title = "Done"
            navigationItem.rightBarButtonItem?.style = .done
        } else {
            navigationItem.rightBarButtonItem?.title = "Edit"
            navigationItem.rightBarButtonItem?.style = .plain
        }
    }
    
    @objc func addNewFolder() {
        newFolderAlert = UIAlertController(title: "New Folder", message: "Enter a name for this folder.", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [weak self] action in
            if let text = self?.newFolderAlert?.textFields?.first?.text {
                self?.folderNames.append(text)
                if let count = self?.folderNames.count {
                    self?.tableView.insertRows(at: [IndexPath(row: count - 1, section: 0)], with: .automatic)
                }
            }
        }
        newFolderAlert?.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.addTarget(self, action: #selector(self.enableDisableNewFolderSave(_:)), for: .editingChanged)
        }
        
        newFolderAlert?.addAction(UIAlertAction(title: "Cancel", style: .default))
        newFolderAlert?.addAction(saveAction)
        saveAction.isEnabled = false
        newFolderAlert?.actions.forEach{$0.setValue(UIColor(red: 0.88, green: 0.67, blue: 0, alpha: 1), forKey: "titleTextColor")}
        if let ac = newFolderAlert {
            present(ac, animated: true)
        }
        
    }
    
    @objc func enableDisableNewFolderSave(_ sender: UITextField) {
        guard let count = sender.text?.count else { return }
        newFolderAlert?.actions[1].isEnabled = count > 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        cell.textLabel?.text = folderNames[indexPath.row]
        cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            folderNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if editingMode {
            guard let nav = storyboard?.instantiateViewController(withIdentifier: "RenameNav") as? UINavigationController else { return }
            guard let vc = nav.topViewController as? RenameViewController else { return }
            
            vc.name = folderNames[indexPath.row]
            vc.saveName = {
                [weak self] (name) in
                self?.folderNames[indexPath.row] = name
                tableView.reloadData()
            }
            vc.deleteFolder = {
                [weak self] in
                self?.folderNames.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            vc.modalPresentationStyle = .pageSheet
            present(nav, animated: true)
        } else {
            guard let nvc = storyboard?.instantiateViewController(withIdentifier: "Notes") as? NotesViewController else { return }
            nvc.folderName = folderNames[indexPath.row]
            navigationController?.pushViewController(nvc, animated: true)
        }
    }
    
    func saveInfo() {
        let ud = UserDefaults()
        ud.set(folderNames, forKey: "folders")
    }

}
