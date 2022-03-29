//
//  ViewController.swift
//  DadJokes
//
//  Created by Aleksandr on 17/03/22.
//

import UIKit

final class DadJokeViewController: UIViewController {

    @IBOutlet var jokeLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    private let requestService = DadJokeRequestService()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadJoke()
    }

    // MARK: - IBActions

    @IBAction private func onNextButton(_ sender: UIButton) {
        loadJoke()
    }

    // MARK: - Private methods

    private func loadJoke() {
        activityIndicator.showAndStart()

        Task(priority: .high) {
            let result = await requestService.getRandomJoke()
            switch result {
                case .success(let joke):
                    await showJoke(joke.joke)
                case .failure(let error):
                    await showErrorAlert(withMessage: error.message)
            }
            await MainActor.run { self.activityIndicator.hideAndStop() }
        }
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
    private func showErrorAlert(withMessage message: String) async {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default , handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
}
