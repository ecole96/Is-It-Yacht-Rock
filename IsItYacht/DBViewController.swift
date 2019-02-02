//
//  DBViewController.swift
//  IsItYacht
//
//  Created by Evan Cole on 9/11/18.
//  Copyright © 2018 Evan Cole. All rights reserved.
//

import UIKit
import CoreData

class DBViewController : UITableViewController, UISearchResultsUpdating {
    var context: NSManagedObjectContext!
    var filteredResults: [DBEntry]?
    var controller: NSFetchedResultsController<NSFetchRequestResult>!
    var predicate: NSCompoundPredicate? = nil
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        super.viewDidLoad()
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<DBEntry>(entityName: "DBEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "artist", ascending:true)]
        controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil) as? NSFetchedResultsController<NSFetchRequestResult>
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.barTintColor = UIColor(red:0.53, green:0.53, blue:0.56, alpha:1.0)
        searchController.searchBar.tintColor = UIColor.white
        if #available(iOS 11.0, *) { // smart punctuation (iOS 11+) will fail to match, so disabling it here
            searchController.searchBar.smartDashesType = .no
            searchController.searchBar.smartQuotesType = .no
            searchController.searchBar.smartInsertDeleteType = .no
        }
        self.tableView.backgroundView = UIView()
        self.definesPresentationContext = true
    }
    
    // search string matching
    func updateSearchResults(for searchController: UISearchController) {
        var goodSearch = false
        var trimmedSearch: String?
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            trimmedSearch = trimWhitespace(string:searchText)
            if !trimmedSearch!.isEmpty {
                goodSearch = true
            }
        }
        
        if !goodSearch { //empty search, show all
            predicate = nil
        }
        else {
            print("Search term:",trimmedSearch!)
            let words = trimmedSearch!.components(separatedBy: " ")
            var subpredicates = [NSPredicate]()
            for word in words {
                let p = NSPredicate(format: "(artist CONTAINS[cd] %@ OR title CONTAINS[cd] %@)",word,word)
                subpredicates.append(p)
            }
            predicate = NSCompoundPredicate(type: .and, subpredicates:subpredicates)
            filteredResults = controller.fetchedObjects?.filter() {
                return predicate!.evaluate(with:$0) } as! [DBEntry]?
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        do {
            try controller.performFetch() }
        catch {
            print("Error fetching database") }
        
        guard let results = controller.fetchedObjects else {return}
        if !results.isEmpty {
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if predicate == nil {
            return controller.sections?[section].numberOfObjects ?? 0
        }
        return filteredResults?.count ?? 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if predicate == nil {
            return controller.sections?.count ?? 0
        }
        return 1
    }
    
    // display cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongCell
        var item: DBEntry
        if predicate == nil {
            item = controller.object(at: indexPath) as! DBEntry }
        else {
            item = filteredResults![indexPath.row] }
        
        cell.songLabel?.text = item.title
        cell.artistLabel?.text = item.artist
        cell.YoNLabel?.text = item.yachtOrNyacht
        cell.YoNLabel?.textColor = scoreLabelColor(score: item.yachtski)
        
        if item.imageURL != nil {
            cell.coverArt?.sd_setImage(with: URL(string: item.imageURL!), placeholderImage: #imageLiteral(resourceName: "coverart-placeholder"))
        }
        else {
            let img = #imageLiteral(resourceName: "coverart-placeholder")
            cell.coverArt?.image = img
        }
        
        return cell
    }
    
    // select cell, move to results page
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var item: DBEntry
        if predicate == nil {
            item = controller.object(at: indexPath) as! DBEntry }
        else {
            item = filteredResults![indexPath.row] }
        let song = Song(title: item.title, artist: item.artist, yachtski: item.yachtski, show: item.show, jd: item.jd, steve: item.steve, hunter: item.hunter, dave: item.dave, imageURL: item.imageURL)
        transitionToResults(vc: self, song: song)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
