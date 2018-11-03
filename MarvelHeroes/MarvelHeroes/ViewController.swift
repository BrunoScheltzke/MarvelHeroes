//
//  ViewController.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

private let cellId = "cellId"

class ViewController: UIViewController {
    var vm: HeroListViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    private let spinner = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let marvelService = MarvelAPIService()
        vm = HeroListViewModel(marvelService: marvelService)
        vm.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        vm.fetchHeroes()
        
        spinner.color = UIColor.darkGray
        spinner.hidesWhenStopped = true
        tableView.tableFooterView = spinner
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let hero = vm.heroesCellViewModel[indexPath.row]
        cell.textLabel?.text = hero.name
        hero.delegate = cell
        hero.startLoadingImage()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.heroesCellViewModel.count
    }
}

extension UITableViewCell: ImageDelegate {
    func finishedLoadingImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.imageView?.image = image
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numRows = tableView.numberOfRows(inSection: 0)
        if (indexPath.row == numRows - 1) {
            spinner.startAnimating()
            vm.fetchHeroes()
        }
    }
}

extension ViewController: HeroListDelegate {
    func present(_ error: Error) {
        
    }
    
    func receivedHeroes(indexPathsToInsert: [IndexPath]) {
        spinner.stopAnimating()
        tableView.beginUpdates()
        tableView.insertRows(at: indexPathsToInsert, with: .automatic)
        tableView.endUpdates()
    }
}
