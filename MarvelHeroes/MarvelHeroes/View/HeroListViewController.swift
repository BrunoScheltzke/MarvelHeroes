//
//  HeroListViewController.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

private let cellId = "heroCell"
private let footerViewId = "footerView"
private let heroDetailSegue = "heroDetailSegue"

class HeroListViewController: UIViewController {
    private var vm: HeroListViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    // Activity indicator to represent the load of extra heroes
    private let spinner = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let marvelService = MarvelAPIService()
        let viewModel = HeroListViewModel(marvelService: marvelService)
        
        setupViewModel(viewModel)
        setupCollectionView()
        setupSpinner()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupSpinner() {
        spinner.color = UIColor.white
        spinner.hidesWhenStopped = true
    }
    
    func setupViewModel(_ viewModel: HeroListViewModel) {
        vm = viewModel
        vm.delegate = self
        view.lock()
        vm.fetchHeroes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == heroDetailSegue,
            let vc = segue.destination as? HeroDetailViewController,
            let heroDetailVM = sender as? HeroDetailViewModel {
            vc.heroDetailViewModel = heroDetailVM
        }
    }
}

extension HeroListViewController: UICollectionViewDataSource {
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
    
    // Adds activity indicator at bottom of collection view to present a loading animation while fetching extra heroes.
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

extension HeroListViewController: UICollectionViewDelegateFlowLayout {
    // Calculating collection view cell size to make sure two collumns are presented
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  50
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize)
    }
}

extension HeroListViewController: UICollectionViewDelegate {
    // If last cell is about to be displayed, try to fetch extra heroes to present to user
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let numRows = collectionView.numberOfItems(inSection: 0)
        if (indexPath.row == numRows - 1) {
            spinner.startAnimating()
            vm.fetchHeroes()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let heroDetailVM = vm.getHeroDetailViewModel(forRow: indexPath.row)
        performSegue(withIdentifier: heroDetailSegue, sender: heroDetailVM)
    }
}

extension HeroListViewController: HeroListDelegate {
    func received(_ error: Error) {
        view.unlock()
        spinner.stopAnimating()
        present(error: error)
    }
    
    func receivedHeroes(indexPathsToInsert: [IndexPath]) {
        view.unlock()
        spinner.stopAnimating()
        collectionView.insertItems(at: indexPathsToInsert)
    }
}
