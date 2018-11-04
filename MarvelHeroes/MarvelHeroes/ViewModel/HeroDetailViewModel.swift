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
    
    func fetchHeroComics(_ completion: @escaping(Result<[IndexPath]>) -> Void ) {
        guard !isFetching else { return }
        isFetching = true
        
        guard !hasReachedMaxAmountOfComics else {
            completion(.success([]))
            return
        }
        
        marvelService.requestComics(of: hero, offset: comicViewModels.count, amount: defaultAmountOfComics) { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.isFetching = false
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let response):
                strongSelf.hasReachedMaxAmountOfComics = response.hasReachedMaxAmount
                let newComics = response.0
                let newComicsVM = newComics.map { ComicViewModel(marvelService: strongSelf.marvelService, comic: $0) }
                strongSelf.comicViewModels.append(contentsOf: newComicsVM)
                let indexPaths = strongSelf.getIndexPathsToInsert(newComics: newComicsVM)
                completion(.success(indexPaths))
            }
        }
    }
    
    /// Calculate index paths that collection view needs to reload based on new comics
    private func getIndexPathsToInsert(newComics: [ComicViewModel]) -> [IndexPath] {
        let startIndex = comicViewModels.count - newComics.count
        let endIndex = startIndex + newComics.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 1) }
    }
    
    func fetchHeroDetailImage(_ completion: @escaping(UIImage) -> Void) {
        guard let imageURL = hero.imageURL else {
            completion(#imageLiteral(resourceName: "marvellogo"))
            return
        }
        
        marvelService.fetchImage(imgURL: imageURL, with: .heroDetail) { result in
            switch result {
            case .failure: completion(#imageLiteral(resourceName: "marvellogo"))
            case .success(let image): completion(image)
            }
        }
    }
}
