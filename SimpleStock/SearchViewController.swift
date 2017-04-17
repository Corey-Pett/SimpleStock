//
//  SearchTableViewController.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/14/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import UIKit
import CoreData

final class SearchViewController: UIViewController, UISearchControllerDelegate {

    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    
    fileprivate lazy var searchController: UISearchController = {
       
        var searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false

        return searchController
    }()
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Stock>!
    fileprivate let cacheName = "Cache"
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableHeaderView = searchController.searchBar
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)

        reloadData(filterText: nil)
    }
    
    // MARK: - Private functions
    
    fileprivate func reloadData(filterText: String?) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        
        fetchRequest.predicate = nil
        
        if let filterText = filterText {
            
            // Purge current cache when updating predicate
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: cacheName)
            
            fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", filterText)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController =
            NSFetchedResultsController(fetchRequest: fetchRequest,
                                       managedObjectContext: appDelegate.persistentContainer.viewContext,
                                       sectionNameKeyPath: nil,
                                       cacheName: cacheName)
        do {
            
            try fetchedResultsController.performFetch()
            self.tableView.reloadData()
            
        } catch let error {
            print(error) // PRESENT ALERT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        }
    }

}

// MARK: - UITableView Data Source

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier, for: indexPath) as! SearchTableViewCell
        
        let stock = fetchedResultsController.object(at: indexPath)
        cell.configure(stock: stock)
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if fetchedResultsController != nil {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        } else {
            return 0
        }
    }
}

// MARK: - UITableView Delegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - UISearchResults Delegate

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData(filterText: searchController.searchBar.text)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.reloadData(filterText: nil)
    }
}
