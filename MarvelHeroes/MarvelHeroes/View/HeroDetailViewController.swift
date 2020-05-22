//
//  HeroDetailViewController.swift
//  MarvelHeroes
//
//  Created by Bruno Scheltzke on 03/11/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

let comicCellId = "comicCell"
let descriptionCell = "descriptionCell"
let comicSegue = "comicSegue"

class HeroDetailViewController: UIViewController {
    var heroDetailViewModel: HeroDetailViewModel!
    
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heroImageViewHeightConstraint: NSLayoutConstraint!
    
    private let spinner = UIActivityIndicatorView(style: .gray)
    
    // The variant sizes the header view can be
    let headerViewDefaultHeight: CGFloat = 300
    let headerViewMinimunHeight: CGFloat = 100
    let headerViewMaxHeight: CGFloat = 400
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupViewModel()
        setupNavBar()
    }
    
    func setupNavBar() {
        let barButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(getMostExpensiveComic))
        barButton.title = "Most expensive comic"
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func getMostExpensiveComic() {
        heroDetailViewModel.fetchMostExpensiveComic { result in
            switch result {
            case .failure(let error): self.present(error: error)
            case .success(let comicVM): self.performSegue(withIdentifier: comicSegue, sender: comicVM)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ComicViewController,
            let viewModel = sender as? ComicViewModel {
            destination.setup(with: viewModel)
        }
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: headerViewDefaultHeight, left: 0, bottom: 0, right: 0)
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        
        spinner.color = .white
        tableView.tableFooterView = spinner
    }
    
    func setupViewModel() {
        fetchHeroImage()
        view.lock()
        fetchComics()
        title = heroDetailViewModel.name
    }
    
    func fetchHeroImage() {
        heroDetailViewModel.fetchHeroDetailImage { [unowned self] image in
            DispatchQueue.main.async {
                self.heroImageView.image = image
            }
        }
    }
    
    func fetchComics() {
        heroDetailViewModel.fetchHeroComics { [unowned self] result in
            self.view.unlock()
            self.spinner.stopAnimating()
            
            switch result {
            case .failure(let error): self.present(error: error)
            case .success(let indexPaths):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
}

extension HeroDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: descriptionCell, for: indexPath)
            cell.textLabel?.text = heroDetailViewModel.description
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: comicCellId, for: indexPath) as? ComicTableViewCell else { return UITableViewCell() }
            cell.setViewModel(heroDetailViewModel.comicViewModels[indexPath.row])
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return heroDetailViewModel.comicViewModels.count
        default: return 0
        }
    }
}

extension HeroDetailViewController: UIScrollViewDelegate, UITableViewDelegate {
    // MARK: Scroll header animation
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = headerViewDefaultHeight - (scrollView.contentOffset.y + headerViewDefaultHeight)
        heroImageViewHeightConstraint.constant = min(max(y, headerViewMinimunHeight), headerViewMaxHeight)
    }
    
    // If last cell is about to be displayed, try to fetch extra heroes to present to user
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !heroDetailViewModel.hasReachedMaxAmountOfComics else { return }
        
        let numRows = tableView.numberOfRows(inSection: 1)
        if (indexPath.row == numRows - 1) {
            spinner.startAnimating()
            fetchComics()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        performSegue(withIdentifier: comicSegue, sender: heroDetailViewModel.comicViewModels[indexPath.row])
    }
}
