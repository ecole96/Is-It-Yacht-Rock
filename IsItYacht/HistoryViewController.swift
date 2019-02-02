//
//  SecondViewController.swift
//  Yacht or Nyacht
//
//  Created by Evan Cole on 9/3/18.
//  Copyright © 2018 Evan Cole. All rights reserved.
//

import UIKit
import CoreData

// class for recording history pane
class HistoryViewController: UITableViewController {
    var context: NSManagedObjectContext!
    var controller: NSFetchedResultsController<NSFetchRequestResult>!

    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        super.viewDidLoad()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<HistoryEntry>(entityName: "HistoryEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending:false)]
        controller = (NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "date_header", cacheName: nil) as! NSFetchedResultsController<NSFetchRequestResult>)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        do {
            try controller.performFetch() }
        catch {
            print("Error fetching history") }
        
        guard let results = controller.fetchedObjects else {return}
        if !results.isEmpty {
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.sections?[section].numberOfObjects ?? 0
    }
    
    // sections grouped by recording date
    override func tableView(_ tableView : UITableView,  titleForHeaderInSection section: Int)->String? {
        guard let sectionInfo = controller.sections?[section] else {
            return nil
        }
        return sectionInfo.name
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return controller.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    // display cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongCell
        let item = controller.object(at: indexPath) as! HistoryEntry
        
        cell.songLabel?.text = item.title
        cell.artistLabel?.text = item.artist
        cell.YoNLabel?.text = item.yachtOrNyacht
        cell.YoNLabel?.textColor = scoreLabelColor(score: item.yachtski as! Float?)
        
        if item.imageURL != nil {
            cell.coverArt?.sd_setImage(with: URL(string: item.imageURL!), placeholderImage: #imageLiteral(resourceName: "coverart-placeholder"))
        }
        else {
            let img = #imageLiteral(resourceName: "coverart-placeholder")
            cell.coverArt?.image = img
        }
        
        return cell
    }
    
    // select cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = controller.object(at: indexPath) as! HistoryEntry
        
        let song = Song(title: item.title, artist: item.artist, yachtski: item.yachtski as! Float?, show: item.show, jd: item.jd as! Float?, steve: item.steve as! Float?, hunter: item.hunter as! Float?, dave: item.dave as! Float?, imageURL: item.imageURL)
        transitionToResults(vc: self, song: song)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
