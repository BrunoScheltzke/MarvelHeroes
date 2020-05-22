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
    
    var totalOfHeroComics: Int? = nil
    
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
        let offset = comicViewModels.count
        let amount = defaultAmountOfComics
        marvelService.requestComics(of: hero, offset: offset, amount: amount) { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.isFetching = false
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let response):
                strongSelf.totalOfHeroComics = response.totalAmount
                strongSelf.hasReachedMaxAmountOfComics = response.totalAmount <= offset + amount
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
    
    func fetchMostExpensiveComic(_ completion: @escaping(Result<ComicViewModel>) -> Void) {
        marvelService.requestComics(of: hero, offset: 0, amount: totalOfHeroComics ?? 0) { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let resultFetched):
                let comics = resultFetched.0
                
                if let mostExpensiveComic = comics.max(by: { $0.getMostExpensivePrice() ?? 0 < $1.getMostExpensivePrice() ?? 0 }) {
                    completion(.success(ComicViewModel(marvelService: self.marvelService, comic: mostExpensiveComic)))
                } else {
                    completion(.failure(CustomError.invalidData))
                }
            }
        }
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
