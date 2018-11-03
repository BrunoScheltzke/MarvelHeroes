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
    let comicNames: [String]
    var delegate: ImageDelegate?
    
    private let hero: Hero
    private let marvelService: MarvelAPIServiceProtocol
    
    init(marvelService: MarvelAPIServiceProtocol, hero: Hero) {
        self.name = hero.name ?? "Name unavailable"
        self.description = hero.description ?? "Description unavailable"
        self.comicNames = hero.comics.map { $0.name }
        self.hero = hero
        self.marvelService = marvelService
    }
    
    func startLoadingImage() {
        guard let imageURL = hero.imageURL else {
            delegate?.finishedLoadingImage(#imageLiteral(resourceName: "marvellogo"))
            return
        }
        
        marvelService.fetchImage(imgURL: imageURL) { [unowned self] result in
            switch result {
            case .failure: self.delegate?.finishedLoadingImage(#imageLiteral(resourceName: "marvellogo"))
            case .success(let image):
                self.delegate?.finishedLoadingImage(image)
            }
        }
    }
}
