//
//  UIActivityIndicator+Visibility.swift
//  DadJokes
//
//  Created by Aleksandr on 31/03/22.
//

import Foundation
import UIKit

extension UIActivityIndicatorView {

    func showAndStart(duration: TimeInterval = 0.3) {
        self.alpha = 0.0
        UIView.animate(withDuration: duration) {
            self.startAnimating()
            self.alpha = 1.0
        }
    }

    func hideAndStop(duration: TimeInterval = 0.3) {
        self.alpha = 1.0
        UIView.animate(withDuration: duration) {
            self.stopAnimating()
            self.alpha = 0.0
        }
    }

}
