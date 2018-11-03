//
//  ViewController.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

private let cellId = "heroCell"
private let footerViewId = "footerView"

class ViewController: UIViewController {
    private var vm: HeroListViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let spinner = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let marvelService = MarvelAPIService()
        vm = HeroListViewModel(marvelService: marvelService)
        vm.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        vm.fetchHeroes()
        
        spinner.color = UIColor.white
        spinner.hidesWhenStopped = true
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.heroesCellViewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as?
            HeroCollectionViewCell else { return UICollectionViewCell() }
        let heroVM = vm.heroesCellViewModel[indexPath.row]
        cell.setViewModel(heroVM)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: footerViewId,
                                                                             for: indexPath)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            footerView.addSubview(spinner)
            spinner.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
            return footerView
        default:
           assert(false, "Unexpected element kind")
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let numRows = collectionView.numberOfItems(inSection: 0)
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
        collectionView.insertItems(at: indexPathsToInsert)
    }
}
