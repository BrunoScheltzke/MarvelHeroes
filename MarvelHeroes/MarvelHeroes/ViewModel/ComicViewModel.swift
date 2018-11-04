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
    var delegate: ImageDelegate?
    let placeholderImage: UIImage = #imageLiteral(resourceName: "marvellogo")
    
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
    }
    
    func startLoadingImage() {
        guard let imageURL = comic.imageURL else {
            delegate?.finishedLoadingImage(#imageLiteral(resourceName: "marvellogo"))
            return
        }

        marvelService.fetchImage(imgURL: imageURL, with: .comicList) { [unowned self] result in
            switch result {
            case .failure: self.delegate?.finishedLoadingImage(#imageLiteral(resourceName: "marvellogo"))
            case .success(let image):
                self.delegate?.finishedLoadingImage(image)
            }
        }
    }
}
