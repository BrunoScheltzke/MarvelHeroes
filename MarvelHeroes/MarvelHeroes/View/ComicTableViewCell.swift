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
    
    func setViewModel(_ comicVM: ComicViewModel) {
        self.comicTitleLabel.text = comicVM.title
        comicVM.delegate = self
        comicVM.startLoadingImage()
        comicImageView.image = comicVM.placeholderImage
        comicImageView.lock()
    }
}

extension ComicTableViewCell: ImageDelegate {
    func finishedLoadingImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.comicImageView.image = image
            self.comicImageView.unlock()
        }
    }
}
