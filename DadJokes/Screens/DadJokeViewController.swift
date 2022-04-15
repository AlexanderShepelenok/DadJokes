//
//  ViewController.swift
//  DadJokes
//
//  Created by Aleksandr on 17/03/22.
//

import UIKit
import CoreGraphics

final class DadJokeViewController: UIViewController {

    @IBOutlet private var jokeLabel: UILabel!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var shareButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

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

    // MARK: - IBActions

    @IBAction private func onNextButton(_ sender: UIButton) {
        loadJoke()
    }

    @IBAction private func onSaveButton(_ sender: UIButton) {
        addToFavorites()
    }

    @IBAction private func onShareButton(_ sender: UIButton) {
        share()
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

    private func calculateShareCaptureRect() -> CGRect {
        let offset: CGFloat = 20.0
        let x = jokeLabel.frame.origin.x - offset
        let y = offset
        let width = jokeLabel.frame.width + offset * 2
        let height = jokeLabel.frame.maxY
        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func share() {
        let captureRect = calculateShareCaptureRect()
        let renderer = UIGraphicsImageRenderer(bounds: captureRect)
        let image = renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }

    // MARK: - Private MainActors

    @MainActor
    private func showJoke(_ joke: String) async {
        self.jokeLabel.alpha = 0.0
        self.jokeLabel.text = joke
        UIView.animate(withDuration: 0.3) {
            self.jokeLabel.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }

}
