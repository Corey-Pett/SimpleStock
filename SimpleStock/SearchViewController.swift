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
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()
    
    fileprivate lazy var stocks = [Stock]()
    fileprivate lazy var filteredStocks = [Stock]()
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
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

        if let filterText = filterText {
            fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", filterText)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asynchronousFetchResult) -> Void in
        
            DispatchQueue.main.async(execute: { () -> Void in
                if let stocks = asynchronousFetchResult.finalResult {
                    if filterText != nil {
                        self.filteredStocks = stocks
                    } else {
                        self.stocks = stocks
                    }
                    
                    self.tableView.reloadData()
                }
            })
        }

        do {
            try appDelegate.persistentContainer.viewContext.execute(asynchronousFetchRequest)            
        } catch let error {
            NotificationManager().presentSimpleAlertOn(vc: self, title: "Oh snap", message: "You are going to have to redownload the app: \(error)")
        }
    }
}

// MARK: - UITableView Data Source

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier, for: indexPath) as! SearchTableViewCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.configure(stock: filteredStocks[indexPath.row])
        } else {
            cell.configure(stock: stocks[indexPath.row])
        }
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredStocks.count
        }
        return stocks.count
    }
}

// MARK: - UITableView Delegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)

        guard let chartViewController = Storyboard.chart.storyboard.instantiateViewController(
            withIdentifier: "rootChart") as? ChartViewController else {
                return
        }
        
        if searchController.isActive && searchController.searchBar.text != "" {
            chartViewController.stock = filteredStocks[indexPath.row]
        } else {
            chartViewController.stock = stocks[indexPath.row]
        }
        
        navigationController?.pushViewController(chartViewController, animated: true)
        
    }
}

// MARK: - UISearchResults Delegate

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData(filterText: searchController.searchBar.text)
    }
}
