//
//  HeroDetailViewModel.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

final class HeroDetailViewModel {
    let name: String
    let description: String
    var comicViewModels: [ComicViewModel] = []
    var delegate: HeroDetailDelegate?
    
    var hasReachedMaxAmountOfComics: Bool = false
    
    private var isFetching: Bool = false
    
    private let defaultAmountOfComics = 10
    
    private let hero: Hero
    private let marvelService: MarvelAPIServiceProtocol
    
    init(marvelService: MarvelAPIServiceProtocol, hero: Hero) {
        if let name = hero.name, !name.isEmpty {
            self.name = name
        } else {
            self.name = "Name unavailable"
        }
        
        if let description = hero.description, !description.isEmpty {
            self.description = description
        } else {
            self.description = "Description unavailable"
        }
        
        self.hero = hero
        self.marvelService = marvelService
    }
    
    func fetchHeroComics() {
        guard !isFetching, !hasReachedMaxAmountOfComics else { return }
        
        isFetching = true
        
        marvelService.requestComics(of: hero, offset: comicViewModels.count, amount: defaultAmountOfComics) { [unowned self] result in
            self.isFetching = false
            switch result {
            case .failure(let error): self.delegate?.received(error)
            case .success(let result):
                let newComics = result.0
                self.hasReachedMaxAmountOfComics = result.hasReachedMaxAmount
                let newComicsVM = newComics.map { ComicViewModel(marvelService: self.marvelService, comic: $0) }
                self.comicViewModels.append(contentsOf: newComicsVM)
                let indexPaths = self.getIndexPathsToInsert(newComics: newComicsVM)
                self.delegate?.finishedFetchingHeroComics(with: indexPaths)
            }
        }
    }
    
    /// Calculate index paths that collection view needs to reload based on new comics
    private func getIndexPathsToInsert(newComics: [ComicViewModel]) -> [IndexPath] {
        let startIndex = comicViewModels.count - newComics.count
        let endIndex = startIndex + newComics.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 1) }
    }
    
    func startLoadingImage() {
        guard let imageURL = hero.imageURL else {
            delegate?.finishedLoadingImage(#imageLiteral(resourceName: "marvellogo"))
            return
        }
        
        marvelService.fetchImage(imgURL: imageURL, with: .heroDetail) { [unowned self] result in
            switch result {
            case .failure: self.delegate?.finishedLoadingImage(#imageLiteral(resourceName: "marvellogo"))
            case .success(let image): self.delegate?.finishedLoadingImage(image)
            }
        }
    }
}

protocol HeroDetailDelegate: ImageDelegate {
    func finishedFetchingHeroComics(with indexPaths: [IndexPath])
    func received(_ error: Error)
}
