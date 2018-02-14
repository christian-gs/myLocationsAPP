//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Christian on 2/14/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreData

class LocationsViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
            let fetchRequest = NSFetchRequest<Location>()
            let entity = Location.entity()
            fetchRequest.entity = entity
            // sort locations by category and date
            let sort1 = NSSortDescriptor(key: "category", ascending: true)
            let sort2 = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [sort1, sort2]
            fetchRequest.fetchBatchSize = 20
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
            fetchedResultsController.delegate = self
            return fetchedResultsController
    }()

    deinit {
        fetchedResultsController.delegate = nil
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Saved Locations"
        navigationItem.rightBarButtonItem = editButtonItem
        performFetch()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.register(SubTitleTableViewCell.self, forCellReuseIdentifier: "subTitleCell")
    }

    func loadCoreData() {
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchRequest.entity = entity
        // sort locations by their date value
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }

    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationsViewController = LocationDetailsViewController(locationToEdit: fetchedResultsController.object(at: indexPath))
        locationsViewController.managedObjectContext = self.managedObjectContext
        navigationController?.pushViewController(locationsViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(location)
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.configureLocationCell(indexPath: indexPath)
        return cell
    }

    func configureLocationCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subTitleCell") as? SubTitleTableViewCell
        let currentLocation = fetchedResultsController.object(at: indexPath)

        //remove white space from location description string
        let trimmedDescription = currentLocation.locationDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        cell?.textLabel?.text = trimmedDescription == "" ? "(No Description)" : currentLocation.locationDescription

        cell?.detailTextLabel?.text = currentLocation.address
        return cell!
    }

    func configureLocationCell(cell: SubTitleTableViewCell, indexPath: IndexPath) {
        let currentLocation = fetchedResultsController.object(at: indexPath)

        //remove white space from location description string
        let trimmedDescription = currentLocation.locationDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.textLabel?.text = trimmedDescription == "" ? "(No Description)" : currentLocation.locationDescription

        cell.detailTextLabel?.text = currentLocation.address
    }
}

// MARK:- NSFetchedResultsController Delegate Extension
extension LocationsViewController:
NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                print("*** NSFetchedResultsChangeInsert (object)")
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                print("*** NSFetchedResultsChangeDelete (object)")
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                print("*** NSFetchedResultsChangeUpdate (object)")
                if let cell = tableView.cellForRow(at: indexPath!) as! SubTitleTableViewCell?  {
                    configureLocationCell(cell: cell, indexPath: indexPath!)
                }
            case .move:
                print("*** NSFetchedResultsChangeMove (object)")
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
    didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
