//
//  ItemsViewController.swift
//  Borrowers
//
//  Created by Wojciech Karaś on 28/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit
import CoreData

class ItemsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var itemsLabel: UILabel!
    
    var borrower: Borrower! {
        didSet {
            navigationItem.title = borrower.name
        }
    }
    var itemsFetchResultController: NSFetchedResultsController<Item>!
    
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "d MMM yyyy"
        
        itemsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 27))
        itemsLabel.font = itemsLabel.font.withSize(14)
        itemsLabel.textAlignment = .center
        itemsLabel.text = ""
        let toolbarTitle = UIBarButtonItem(customView: itemsLabel)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [flexible, toolbarTitle, flexible]
        navigationController?.isToolbarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    private func getData() {
        do {
            let request = Item.fetchRequest() as NSFetchRequest<Item>
            request.predicate = NSPredicate(format: "borrower = %@", borrower)
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Item.date), ascending: true)]
            itemsFetchResultController = NSFetchedResultsController(fetchRequest: request,
                                                                    managedObjectContext: context,
                                                                    sectionNameKeyPath: nil,
                                                                    cacheName: nil)
            itemsFetchResultController.delegate = self
            try itemsFetchResultController.performFetch()
        } catch {
            print("Could not fetch. \(error.localizedDescription)")
        }
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Item",
                                      message: "Add an item that you are going to lend to someone.",
                                      preferredStyle: .alert)
        
        alert.addTextField {
            textField in
            textField.placeholder = "Item"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let addAction = UIAlertAction(title: "Add", style: .default) {
            action in
            
            if let text = alert.textFields?.first?.text {
                if !text.isEmpty {
                    let item = Item(entity: Item.entity(), insertInto: self.context)
                    item.date = Date() as NSDate
                    item.itemDescription = text
                    item.borrower = self.borrower
                    self.appDelegate.saveContext()
                }
            }
        }
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - TableView Methods
extension ItemsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = itemsFetchResultController.fetchedObjects?.count ?? 0
        itemsLabel.text = "Items: \(count)"
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemsFetchResultController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = item.itemDescription
        cell.detailTextLabel?.text = dateFormatter.string(from: item.date as Date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        context.delete(itemsFetchResultController.object(at: indexPath))
        appDelegate.saveContext()
    }
}

//MARK: - FetchResultsController Methods
extension ItemsViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        guard let indexPath = indexPath ?? (newIndexPath ?? nil) else {
            return
        }
        switch type {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
        
    }
}
