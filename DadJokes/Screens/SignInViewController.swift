//
//  SignInViewController.swift
//  DadJokes
//
//  Created by Aleksandr on 06/04/22.
//

import Foundation
import UIKit

final class SignInViewController: UIViewController {

    private enum NameValidationError: Error, LocalizedError {
        case emptyName
        case containsSymbols

        var errorDescription: String? {
            switch self {
                case .emptyName:
                    return "Name is empty. Please enter your name."
                case .containsSymbols:
                    return "Name must contain only letters and numbers when creating a new user"
            }
        }
    }

    private enum Constants {
        static let nameFormatRegex = ".*[^A-Za-z0-9].*"
        static let showFavoritesSegueIdentifier = "ShowFavorites"
    }

    let viewControllerFactory: ViewControllerFactory
    let dadJokeRepository: DadJokeRepository

    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var signInButton: UIButton!
    @IBOutlet private var errorLabel: UILabel!

    private var errorText: String? {
        get { errorLabel.text }
        set {
            errorLabel.text = newValue
            errorLabel.isHidden = errorLabel.text?.isEmpty ?? true
        }
    }

    init?(coder: NSCoder,
          viewControllerFactory: ViewControllerFactory,
          dadJokeRepository: DadJokeRepository) {
        self.dadJokeRepository = dadJokeRepository
        self.viewControllerFactory = viewControllerFactory
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - IBSegueActions

    @IBSegueAction
    private func createFavoritesTableViewController(_ coder: NSCoder,
                                                    sender: Any?,
                                                    segueIdentifier: String?) -> UITableViewController? {
        let favoritesViewController = viewControllerFactory.createFavoritesViewController(coder)
        if let name = dadJokeRepository.currentUser?.name {
            favoritesViewController?.title = "\(name)'s favorites"
        }
        return favoritesViewController
    }
    // MARK: - IBActions

    @IBAction private func onSignInClick(_ sender: UIButton) {
        errorText = nil
        do {
            let name = try validateUser(nameInput: nameTextField.text)
            Task(priority: .userInitiated) {
                do {
                try await authenticateUser(withName: name)
                    performSegue(withIdentifier: Constants.showFavoritesSegueIdentifier, sender: self)
                } catch {
                    DispatchQueue.main.async {
                        self.showErrorAlert(withMessage: error.localizedDescription)
                    }
                }
            }
        } catch {
            guard let validationError = error as? NameValidationError else {
                fatalError("Unhandled name validation error")
            }
            errorText = validationError.errorDescription
        }
    }

    @IBAction private func unwind(_ segue: UIStoryboardSegue) {
        dadJokeRepository.logoutCurrentUser()
    }

    // MARK: - Private methods

    private func validateUser(nameInput: String?) throws -> String {
        guard let name = nameInput, !name.isEmpty else {
            throw NameValidationError.emptyName
        }
        guard name.range(of: Constants.nameFormatRegex, options: .regularExpression) == nil else {
            throw NameValidationError.containsSymbols
        }
        return name
    }

    private func authenticateUser(withName name: String) async throws {
        try await dadJokeRepository.authenticateUser(withName: name)
    }

}
