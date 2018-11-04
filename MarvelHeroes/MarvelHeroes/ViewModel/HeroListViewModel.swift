//
//  HeroListViewModel.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

final class HeroListViewModel {
    private var isFetching: Bool = false
    private let marvelService: MarvelAPIServiceProtocol
    
    private let defaultAmountOfHeroes: Int = 20
    
    var hasReachedMaxAmountOfHeroes: Bool = false
    
    var delegate: HeroListDelegate?
    var heroesCellViewModel: [HeroCellViewModel] = []
    
    init(marvelService: MarvelAPIServiceProtocol) {
        self.marvelService = marvelService
    }
    
    func getHeroDetailViewModel(forRow row: Int) -> HeroDetailViewModel {
        let heroVM = heroesCellViewModel[row]
        return heroVM.getHeroDetailViewModel()
    }
    
    func fetchHeroes() {
        guard !isFetching, !hasReachedMaxAmountOfHeroes else { return }
        isFetching = true
        
        marvelService.requestCharacters(offset: heroesCellViewModel.count,
                                        amount: defaultAmountOfHeroes) { [unowned self] result in
            switch result {
            case .failure(let error):
                self.delegate?.received(error)
                
            case .success(let result):
                let newHeroes = result.0
                self.hasReachedMaxAmountOfHeroes = result.hasReachedMaxAmount
                let newHeroesVM = newHeroes.map { HeroCellViewModel(marvelService: self.marvelService, hero: $0) }
                self.heroesCellViewModel.append(contentsOf: newHeroesVM)
                let indexPaths = self.getIndexPathsToInsert(newHeroes: newHeroesVM)
                self.delegate?.receivedHeroes(indexPathsToInsert: indexPaths)
            }
            self.isFetching = false
        }
    }
    
    /// Calculate index paths that collection view needs to reload based on new heroes
    private func getIndexPathsToInsert(newHeroes: [HeroCellViewModel]) -> [IndexPath] {
        let startIndex = heroesCellViewModel.count - newHeroes.count
        let endIndex = startIndex + newHeroes.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}

protocol HeroListDelegate {
    func received(_ error: Error)
    func receivedHeroes(indexPathsToInsert: [IndexPath])
}
