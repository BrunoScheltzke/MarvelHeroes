//
//  UIViewController.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 03/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

extension UIViewController {
    func present(message: String) {
        let alert = UIAlertController(title: "Marvel Heroes", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func present(error: Error) {
        present(message: error.localizedDescription)
    }
}
