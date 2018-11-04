//
//  HeroCellViewModel.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 02/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

final class HeroCellViewModel {
    let name: String
    var delegate: ImageDelegate?
    let placeholderImage: UIImage = #imageLiteral(resourceName: "marvellogo")
    
    private let hero: Hero
    private let marvelService: MarvelAPIServiceProtocol
    
    init(marvelService: MarvelAPIServiceProtocol, hero: Hero) {
        self.hero = hero
        self.marvelService = marvelService
        self.name = hero.name ?? "Name unavailable"
    }
    
    func startLoadingImage() {
        guard let imageURL = hero.imageURL else {
            delegate?.finishedLoadingImage(#imageLiteral(resourceName: "marvellogo"))
            return
        }
        
        marvelService.fetchImage(imgURL: imageURL, with: .heroList) { [unowned self] result in
            switch result {
            case .failure: self.delegate?.finishedLoadingImage(#imageLiteral(resourceName: "marvellogo"))
            case .success(let image):
                self.delegate?.finishedLoadingImage(image)
            }
        }
    }
    
    func getHeroDetailViewModel() -> HeroDetailViewModel {
        return HeroDetailViewModel(marvelService: marvelService, hero: hero)
    }
}

protocol ImageDelegate {
    func finishedLoadingImage(_ image: UIImage)
}
