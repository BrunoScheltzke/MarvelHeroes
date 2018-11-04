//
//  ComicTableViewCell.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 03/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class ComicTableViewCell: UITableViewCell {
    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var comicTitleLabel: UILabel!
    @IBOutlet weak var comicDetailLabel: UILabel!
    
    private var comicViewModel: ComicViewModel!
    
    func setViewModel(_ comicVM: ComicViewModel) {
        self.comicViewModel = comicVM
        
        self.comicTitleLabel.text = comicVM.title
        fetchComicImage()
    }
    
    func fetchComicImage() {
        comicImageView.image = comicViewModel.placeholderImage
        comicImageView.lock()
        comicViewModel.fetchComicImage { [weak self] image in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.comicImageView.image = image
                strongSelf.comicImageView.unlock()
            }
        }
    }
}
