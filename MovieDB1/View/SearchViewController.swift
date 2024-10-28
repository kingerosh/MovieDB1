//
//  SearchViewController.swift
//  MovieDB1
//
//  Created by Ерош Айтжанов on 11.10.2024.
//

import UIKit
import SnapKit

class SearchViewController:  UIViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            movieData = []
            searchMovieTableView.reloadData()
            return
        }
        apiRequest(searchFor: searchText)
        
    }
    
    lazy var searchMovieTableView: UITableView = {
        let table = UITableView()
        table.alpha = 1
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: "searchMovie")
        return table
    }()
    
    var movieData: [Result] = []
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchMovieTableView.reloadData()
    }
    
    
    func setupUI() {
        view.addSubview(searchMovieTableView)
        
        searchMovieTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            
        }
    }
    
    
    func apiRequest(searchFor: String) {
        NetworkManager.shared.loadSearch(searchFor: searchFor) { result in
            self.movieData = result
            self.searchMovieTableView.reloadData()
            print("Updated data:", self.movieData)
        }
    }
    

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchMovieTableView.dequeueReusableCell(withIdentifier: "searchMovie", for: indexPath) as! MovieTableViewCell
        let movie = movieData[indexPath.row]
        cell.conf(movie: movie)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailViewController = MovieDetailViewController()
        let movieID = movieData[indexPath.row].id
        print(movieID)
        movieDetailViewController.movieID = movieID
        NetworkManager.shared.loadVideo(movieID: movieID) { result in
            let videoID = result.first!.key
            movieDetailViewController.playerView.load(withVideoId: videoID)
            self.navigationController?.pushViewController(movieDetailViewController, animated: true)
        }
    }
    
}

