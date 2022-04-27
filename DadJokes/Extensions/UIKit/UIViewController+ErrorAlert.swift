//
//  UIViewController+ErrorAlert.swift
// 
//
//  Created by Aleksandr on 11/04/22.
//

import Foundation
import UIKit

extension UIViewController {

    func showErrorAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }

}
