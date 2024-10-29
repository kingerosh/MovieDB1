//
//  FavoriteViewController.swift
//  MovieDB
//
//  Created by Ерош Айтжанов on 27.07.2024.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {
    
//    lazy var movieLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Favorites"
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    lazy var startLabel: UILabel = {
        let label = UILabel()
        label.text = "Add favorite movies"
        label.textAlignment = .center
        label.alpha = 0.5
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var movieTableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: "favorite")
        return table
    }()
    
    var movieData:[Result] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Favorites" // Set your title here

        // Set the title display mode to automatic to allow it to shrink
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: animated)
        loadFromCoreData()
        movieTableView.reloadData()
    }
    
    func setupUI() {
        //view.addSubview(movieLabel)
        view.addSubview(movieTableView)
        view.addSubview(startLabel)
//        movieLabel.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
//            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
//        }
        movieTableView.snp.makeConstraints { make in
            //make.top.equalTo(movieLabel.snp.bottom).offset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        startLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func loadFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistantContainer.viewContext
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Favorite")
        do {
            let result = try context.fetch(fetch)
            var movies:[Result] = []
            for data in result as! [NSManagedObject] {
                let movieID = data.value(forKey: "movieID") as! Int
                let title = data.value(forKey: "title") as! String
                let posterPath = data.value(forKey: "posterPath") as! String
                let voteAverage = data.value(forKey: "voteAverage") as! Double
                let movie = Result(id: movieID, posterPath: posterPath, title: title, voteAverage: voteAverage)
                movies.append(movie)
            }
            movieData = movies
            if movieData.isEmpty {
                movieTableView.alpha = 0
                startLabel.alpha = 0.5
            } else {
                startLabel.alpha = 0
                movieTableView.alpha = 1
            }
            
        }
        catch {
            print("error loadCoreData")
        }
    }


}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "favorite", for: indexPath) as! MovieTableViewCell
        let movie = movieData[indexPath.row]
        cell.conf(movie: movie)
        cell.method = { [weak self] in
            self!.loadFromCoreData()
            self!.movieTableView.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailViewController = MovieDetailViewController()
        let movieID = movieData[indexPath.row].id
        movieDetailViewController.movieID = movieID
        NetworkManager.shared.loadVideo(movieID: movieID) { result in
            let videoID = result.first!.key
            movieDetailViewController.playerView.load(withVideoId: videoID)
            self.navigationController?.pushViewController(movieDetailViewController, animated: true)
        }
    }

    
}
