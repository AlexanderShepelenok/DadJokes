//
//  FavoritesTableViewController.swift
//  DadJokes
//
//  Created by Aleksandr on 06/04/22.
//

import UIKit
import CoreData

final class FavoritesTableViewController: UITableViewController {

    let fetchedResultsController: NSFetchedResultsController<CoreDataJoke>
    let jokeRepository: DadJokeRepository

    init?(coder: NSCoder,
          fetchedResultsController: NSFetchedResultsController<CoreDataJoke>,
          jokeRepository: DadJokeRepository) {
        self.fetchedResultsController = fetchedResultsController
        self.jokeRepository = jokeRepository
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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

    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle { .delete }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let joke = fetchedResultsController.object(at: indexPath)
            Task {
                await jokeRepository.removeFromFavorites(joke)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

}

extension FavoritesTableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        // Reload only on insertions. Removal handled manually.
        if !diff.insertions.isEmpty {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
}
