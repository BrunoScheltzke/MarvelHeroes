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
    
    private let defaultAmountOfComics = 10
    
    private let hero: Hero
    private let marvelService: MarvelAPIServiceProtocol
    
    init(marvelService: MarvelAPIServiceProtocol, hero: Hero) {
        self.name = hero.name ?? "Name unavailable"
        self.description = hero.description ?? "Description unavailable"
        self.hero = hero
        self.marvelService = marvelService
    }
    
    func fetchHeroComics() {
        marvelService.requestComics(of: hero, offset: comicViewModels.count, amount: defaultAmountOfComics) { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let newComics):
                let newComicsVM = newComics.map { ComicViewModel(marvelService: self.marvelService, comic: $0) }
                self.comicViewModels.append(contentsOf: newComicsVM)
                let indexPaths = self.getIndexPathsToInsert(newComics: newComicsVM)
                self.delegate?.finishedFetchingHeroComics(with: indexPaths)
            }
        }
    }
    
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
            case .success(let image):
                self.delegate?.finishedLoadingImage(image)
            }
        }
    }
}

protocol HeroDetailDelegate: ImageDelegate {
    func finishedFetchingHeroComics(with indexPaths: [IndexPath])
}
