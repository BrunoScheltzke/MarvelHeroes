//
//  HeroCollectionViewCell.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 03/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class HeroCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    func setViewModel(_ heroVM: HeroCellViewModel) {
        heroVM.delegate = self
        self.heroNameLabel.text = heroVM.name
        heroVM.startLoadingImage()
        self.lock()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadowView.layer.addShadow(with: #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1), alpha: 0.23, xOffset: 0, yOffset: 0, blur: 15, spread: 0)
    }
}

extension HeroCollectionViewCell: ImageDelegate {
    func finishedLoadingImage(_ image: UIImage) {
        self.unlock()
        heroImage.image = image
    }
}
