//
//  ViewController.swift
//  DadJokes
//
//  Created by Aleksandr on 17/03/22.
//

import UIKit

final class DadJokeViewController: UIViewController {

    @IBOutlet private var jokeLabel: UILabel!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var databaseJokesLabel: UILabel!

    private var currentJoke: CoreDataJoke?
    private var currentTask: Task<(), Never>?

    init?(coder: NSCoder, dadJokeRepository: DadJokeRepository) {
        self.jokeRepository = dadJokeRepository
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let jokeRepository: DadJokeRepository

    override func viewDidLoad() {
        super.viewDidLoad()
        loadJoke()
    }

    override func viewWillAppear(_ animated: Bool) {
        saveButton.isEnabled = jokeRepository.currentUser != nil
    }

    // MARK: - IBActions

    @IBAction private func onNextButton(_ sender: UIButton) {
        loadJoke()
    }

    @IBAction private func onSaveButton(_ sender: UIButton) {
        addToFavorites()
    }

    // MARK: - Private methods

    private func loadJoke() {
        activityIndicator.showAndStart()

        if let inProgressTask = currentTask {
            inProgressTask.cancel()
        }

        currentTask = Task(priority: .userInitiated) {
            do {
                let joke = try await jokeRepository.randomJoke()
                await showJoke(joke.text)
                await updateDatabaseJokesLabel()
                self.currentJoke = joke
            } catch {
                DispatchQueue.main.async {
                    self.showErrorAlert(withMessage: error.localizedDescription)
                }
            }
            DispatchQueue.main.async { self.activityIndicator.hideAndStop() }
            self.currentTask = nil
        }
    }

    private func addToFavorites() {
        guard let currentJoke = currentJoke else { return }
        jokeRepository.addToFavorites(joke: currentJoke)
    }

    @MainActor
    private func showJoke(_ joke: String) async {
        self.jokeLabel.alpha = 0.0
        self.jokeLabel.text = joke
        UIView.animate(withDuration: 0.3) {
            self.jokeLabel.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }

    @MainActor
    private func updateDatabaseJokesLabel() async {
        let count = await jokeRepository.databaseJokesCount()
        databaseJokesLabel.text = "Database jokes: \(count)"
    }
}
