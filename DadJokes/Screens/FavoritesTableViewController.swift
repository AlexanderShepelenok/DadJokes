//
//  FavoritesTableViewController.swift
//  DadJokes
//
//  Created by Aleksandr on 06/04/22.
//

import UIKit
import CoreData

final class FavoritesTableViewController: UITableViewController {

    private enum SegueIdentifiers {
        static let unwind = "Unwind"
    }

    @IBOutlet private var logoutButton: UIBarButtonItem!

    let fetchedResultsController: NSFetchedResultsController<CoreDataJoke>

    init?(coder: NSCoder, fetchedResultsController: NSFetchedResultsController<CoreDataJoke>) {
        self.fetchedResultsController = fetchedResultsController
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        fetchedResultsController.delegate = self
        do {
        try fetchedResultsController.performFetch()
        } catch {
            showErrorAlert(withMessage: "Unable to perform fetch from the database")
        }
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - IBActions

    @IBAction private func logoutButtonClick(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueIdentifiers.unwind, sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell",
                                                 for: indexPath)

        let joke = fetchedResultsController.object(at: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = joke.text
        cell.contentConfiguration = config
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView,
     canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView,
     commit editingStyle: UITableViewCell.EditingStyle,
     forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class,
     insert it into the array, and add a new row to the table view
        }    
    }
    */

}

extension FavoritesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}
