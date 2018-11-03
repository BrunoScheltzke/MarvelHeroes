//
//  HeroListViewModel.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

final class HeroListViewModel {
    private var heroes: [Hero] = []
    
    private var isFetching: Bool = false
    private let marvelService: MarvelAPIServiceProtocol
    
    private let defaultAmountOfHeroes: Int = 15
    
    var delegate: HeroListDelegate?
    
    init(marvelService: MarvelAPIServiceProtocol) {
        self.marvelService = marvelService
    }
    
    func fetchHeroes() {
        guard !isFetching else { return }
        
        marvelService.requestCharacters(offset: heroes.count,
                                        amount: 15) { [unowned self] result in
            switch result {
            case .failure(let error):
                self.delegate?.present(error)
            case .success(let newHeroes):
                self.heroes.append(contentsOf: newHeroes)
                let indexPaths = self.getIndexPathsToInsert(newHeroes: newHeroes)
                self.delegate?.receivedHeroes(indexPathsToInsert: indexPaths)
            }
        }
    }
    
    private func getIndexPathsToInsert(newHeroes: [Hero]) -> [IndexPath] {
        let startIndex = heroes.count - newHeroes.count
        let endIndex = startIndex + newHeroes.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    func heroCellViewModel(for row: Int) -> HeroCellViewModel {
        return HeroCellViewModel(marvelService: marvelService, hero: heroes[row])
    }
}

protocol HeroListDelegate {
    func present(_ error: Error)
    func receivedHeroes(indexPathsToInsert: [IndexPath])
}
