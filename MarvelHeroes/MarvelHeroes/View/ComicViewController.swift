//
//  ComicViewController.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 22/05/20.
//  Copyright © 2020 Bruno Scheltzke. All rights reserved.
//

import UIKit

class ComicViewController: UIViewController {

    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private var comicViewModel: ComicViewModel!
    
    func setup(with viewModel: ComicViewModel) {
        self.comicViewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = comicViewModel.title
        descriptionLabel.text = comicViewModel.description
        priceLabel.text = comicViewModel.price
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
