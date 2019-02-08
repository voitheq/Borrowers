//
//  ViewController.swift
//  Borrowers
//
//  Created by Wojciech Karaś on 28/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit
import CoreData

class BorrowersViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    private var borrowersFetchedResultController: NSFetchedResultsController<Borrower>!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var query: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellWidth = (view.frame.size.width - 8) / 2
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize.width = cellWidth
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationController?.isToolbarHidden = !isEditing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = !isEditing
        refreshData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        addButton.isEnabled = !isEditing
        collectionView.allowsMultipleSelection = isEditing
        navigationController?.isToolbarHidden = !isEditing
        setDeleteButton()
        
        for index in collectionView.indexPathsForVisibleItems {
            let borrowerCell = collectionView.cellForItem(at: index) as! BorrowerCell
            borrowerCell.isEditing = isEditing
        }
    }

    private func setDeleteButton() {
        if isEditing {
            if let index = collectionView.indexPathsForSelectedItems {
                if index.count == 0 {
                    deleteButton.isEnabled = false
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddBorrowerSegue" {
            if let addBorrowerViewController = segue.destination as? AddBorrowerViewController {
                addBorrowerViewController.delegate = self
            }
        } else if segue.identifier == "ItemsViewControllerSegue" {
            if let itemsViewController = segue.destination as? ItemsViewController {
                if let indexPath = sender as? IndexPath {
                    itemsViewController.borrower = borrowersFetchedResultController.object(at: indexPath)
                }
            }
        }
    }
    
    private func refreshData() {
        do {
            let request = Borrower.fetchRequest() as NSFetchRequest<Borrower>
            
            if let query = query {
                 request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
            }
            
//            request.sortDescriptors = [NSSortDescriptor(keyPath: \Borrower.name, ascending: true)]
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Borrower.name),
                                                        ascending: true,
                                                        selector: #selector(NSString.caseInsensitiveCompare(_:)))]
            
            borrowersFetchedResultController = NSFetchedResultsController(fetchRequest: request,
                                                                          managedObjectContext: context,
                                                                          sectionNameKeyPath: nil,
                                                                          cacheName: nil)
            borrowersFetchedResultController.delegate = self
            try borrowersFetchedResultController.performFetch()
            collectionView.reloadData()
        } catch {
            print("Could not fetch. \(error.localizedDescription)")
        }
    }
    
    private func updateTitle(count: Int) {
        navigationItem.title = "\(count)"
    }
    
    @IBAction func deleteBorrowers(_ sender: UIBarButtonItem) {
        if let selectedItems = collectionView.indexPathsForSelectedItems?.sorted() {
            for indexPath in selectedItems.reversed() {
                context.delete(borrowersFetchedResultController.object(at: indexPath))
                appDelegate.saveContext()
            }
            setDeleteButton()
        }
    }
}

//MARK: - CollectionView Methods
extension BorrowersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return borrowersFetchedResultController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = borrowersFetchedResultController.sections, let borrowers = sections[section].objects else {
            updateTitle(count: 0)
            return 0
        }
        updateTitle(count: borrowers.count)
        return borrowers.count
        //return borrowersFetchedResultController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let borrower = borrowersFetchedResultController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BorrowerCell", for: indexPath) as! BorrowerCell
        cell.nameLabel.text = borrower.name
        cell.emailLabel.text = borrower.email
        cell.itemsLabel.text = ("(\(borrower.items.count))")
        if let photo = borrower.photo as Data? {
            cell.borrowerPhoto.image = UIImage(data: photo)
        } else {
            cell.borrowerPhoto.image = UIImage(named: "Borrower")
        }
        cell.isEditing = isEditing
        cell.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            performSegue(withIdentifier: "ItemsViewControllerSegue", sender: indexPath)
            collectionView.deselectItem(at: indexPath, animated: true)
        }else{
            deleteButton.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        setDeleteButton()
    }
}

//MARK: - SearchBar Methods
extension BorrowersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            query = !text.isEmpty ? text : nil
        }
        searchBar.resignFirstResponder()
        refreshData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        query = nil
        searchBar.resignFirstResponder()
        refreshData()
    }
}

//MARK: - AddBorrowerDelegate Methods
extension BorrowersViewController: AddBorrowerViewControllerDelegate {
    func addBorrowerViewControllerDidFinishAdding(_ controller: AddBorrowerViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addBorrowerViewControllerDidCancel(_ controller: AddBorrowerViewController) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - FetchedResultsController Methods
extension BorrowersViewController: NSFetchedResultsControllerDelegate {
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
            collectionView.insertItems(at: [indexPath])
        case .delete:
            collectionView.deleteItems(at: [indexPath])
        default:
            break
        }
    }
}
