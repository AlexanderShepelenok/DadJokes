//
//  FavoritesTableViewController.swift
// 
//
//  Created by Aleksandr on 06/04/22.
//

import UIKit
import CoreLayer

final class FavoritesTableViewController: UITableViewController {

    let favoritesProvider: FavoritesProvider
    let favoritesManager: FavoritesManager

    init?(coder: NSCoder,
          favoritesProvider: FavoritesProvider,
          favoritesManager: FavoritesManager) {
        self.favoritesProvider = favoritesProvider
        self.favoritesManager = favoritesManager
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        favoritesProvider.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        favoritesProvider.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoritesProvider.numberOfItems(inSection: section)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell",
                                                 for: indexPath)

        let joke = favoritesProvider.item(at: indexPath)
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
            let joke = favoritesProvider.item(at: indexPath)
            Task {
                await favoritesManager.setFavorite(false, joke: joke)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

extension FavoritesTableViewController: FavoritesProviderDelegate {

    func fetchingFailed(error: Error) {
        showErrorAlert(withMessage: "Unable to perform fetch from the database")
    }

    func favoritesUpdated(insertionsCount: Int, removalsCount: Int) {
        if insertionsCount > 0 {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
}
