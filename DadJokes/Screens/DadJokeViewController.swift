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
    @IBOutlet private var toggleFavoriteButton: UIButton!
    @IBOutlet private var shareButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var currentJoke: CoreDataJoke? {
        didSet {
            refreshFavoriteState()
        }
    }
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
        configureToggleFavoriteButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFavoriteState()
    }

    // MARK: - IBActions

    @IBAction private func onNextButton(_ sender: UIButton) {
        loadJoke()
    }

    @IBAction private func onToggleFavoriteButton(_ sender: UIButton) {
        Task { await toggleFavorite() }
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
                self.showErrorAlert(withMessage: error.localizedDescription)
            }
            DispatchQueue.main.async { self.activityIndicator.hideAndStop() }
            self.currentTask = nil
        }
    }

    private func toggleFavorite() async {
        guard let currentJoke = currentJoke else { return }
        await jokeRepository.toggleFavorite(forJoke: currentJoke)
        self.toggleFavoriteButton.isSelected = currentJoke.inFavorites
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

    private func configureToggleFavoriteButton() {
        toggleFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        toggleFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
    }

    private func refreshFavoriteState() {
        self.toggleFavoriteButton.isSelected = currentJoke?.inFavorites ?? false
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
