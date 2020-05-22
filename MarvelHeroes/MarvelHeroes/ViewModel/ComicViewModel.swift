//
//  ComicViewModel.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 03/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

final class ComicViewModel {
    let title: String
    let placeholderImage: UIImage = #imageLiteral(resourceName: "marvellogo")
    let price: String
    let description: String
    
    private let comic: Comic
    private let marvelService: MarvelAPIServiceProtocol
    
    init(marvelService: MarvelAPIServiceProtocol, comic: Comic) {
        self.comic = comic
        self.marvelService = marvelService
        
        if let title = comic.title, !title.isEmpty {
            self.title = title
        } else {
            self.title = "Title unavailable"
        }
        
        if let priceDouble = self.comic.getMostExpensivePrice() {
            price = "\(priceDouble)"
        } else {
            price = "Price unavailable"
        }
        description = comic.description ?? "Description unavailable"
    }
    
    func fetchComicImage(_ completion: @escaping(UIImage) -> Void) {
        guard let imageURL = comic.imageURL else {
            completion(#imageLiteral(resourceName: "marvellogo"))
            return
        }

        marvelService.fetchImage(imgURL: imageURL, with: .comicList) { result in
            switch result {
            case .failure: completion(#imageLiteral(resourceName: "marvellogo"))
            case .success(let image): completion(image)
            }
        }
    }
}
