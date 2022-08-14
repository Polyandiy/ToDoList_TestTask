//
//  ViewController.swift
//  ToDoList_TestTask
//
//  Created by Поляндий on 14.08.2022.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    var tasks = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CoreData To Do List"
        view.addSubview(tableView)
        getAllItem()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd() {
        let alertController = UIAlertController(title: "Новая задача", message: "Введите задачу", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let tf = alertController.textFields?.first, let text = tf.text, !text.isEmpty else {return}
            self?.createItem(name: text)
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .default) { _ in }
        
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = task.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = tasks[indexPath.row]
         
        let sheetController = UIAlertController(title: "Редактировать", message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Редактировать", style: .default) { _ in
            let editController = UIAlertController(title: "Редактировать данные", message: "Изменить задачу", preferredStyle: .alert)
            editController.addTextField(configurationHandler: nil)
            editController.textFields?.first?.text = item.name
            editController.addAction(UIAlertAction(title: "Сохранить", style: .cancel, handler: { [weak self] _ in
                guard let field = editController.textFields?.first, let newName = field.text, !newName.isEmpty else {return}
                
                self?.updateItem(item: item, newName: newName)
            }))
            self.present(editController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel) { _ in }
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteItem(item: item)
        }
         
        sheetController.addAction(editAction)
        sheetController.addAction(cancelAction)
        sheetController.addAction(deleteAction)
        
        present(sheetController, animated: true, completion: nil)
    }

    
    
    
    // MARK: - Core Data
    
    func getAllItem(){
        do{
            tasks = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print( error.localizedDescription)
        }
    }
    
    func createItem(name: String){
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        
        do{
            try context.save()
            getAllItem()
        } catch let error as NSError {
            print( error.localizedDescription)
        }
    }
    
    func deleteItem(item: ToDoListItem){
        context.delete(item)
        do{
            try context.save()
            getAllItem()
        } catch let error as NSError {
            print( error.localizedDescription)
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String){
        item.name = newName
        getAllItem()
        do{
            try context.save()
        } catch let error as NSError {
            print( error.localizedDescription)
        }
    }
    
    
    
}

