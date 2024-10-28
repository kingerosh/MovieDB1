//
//  ViewController.swift
//  MovieDB
//
//  Created by Ерош Айтжанов on 21.06.2024.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    lazy var movieLabel: UILabel = {
        let label = UILabel()
        label.text = "MovieDB"
        label.alpha = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var themeLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.text = "Theme"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var movieTableView: UITableView = {
        let table = UITableView()
        table.alpha = 0
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: "movie")
        return table
    }()
    
    private func createTableHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60)) // Set desired height
        headerView.backgroundColor = .systemBackground
        headerView.addSubview(themeCollectionView)
        
        themeCollectionView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(50) // Adjust height as needed
        }
        
        return headerView
    }
    
    var movieData: [Result] = []
    
    private let themes: [String] = ["Popular", "Now playing", "Upcoming", "Top Rated"]
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }
    
    private lazy var themeCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.delegate = self
        collection.dataSource = self
        collection.alpha = 1
        collection.backgroundColor = .systemBackground
        collection.showsHorizontalScrollIndicator = false
        collection.register(ThemeCollectionViewCell.self, forCellWithReuseIdentifier: "theme")
        return collection
    
    }()
    
    private lazy var themeView:UIView = {
        let overview = UIView()
        overview.translatesAutoresizingMaskIntoConstraints = false
        overview.backgroundColor = .systemGray5
        return overview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        apiRequest()
        
        movieTableView.tableHeaderView = createTableHeaderView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.movieTableView.reloadData()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLabel()
    }
    
    func setupUI() {
        view.addSubview(movieLabel)
        //view.addSubview(themeLabel)
        //view.addSubview(themeCollectionView)
        view.addSubview(movieTableView)
        
        movieLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view.safeAreaLayoutGuide)
        }
//        themeLabel.snp.makeConstraints { make in
//            make.trailing.equalTo(view.safeAreaLayoutGuide)
//            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
//            make.top.equalTo(movieLabel.snp.bottom)
//        }
//        themeCollectionView.snp.makeConstraints { make in
//            make.top.equalTo(themeLabel.snp.bottom)
//            make.trailing.equalTo(view.safeAreaLayoutGuide)
//            make.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
//            make.height.equalTo(50)
//        }
        movieTableView.snp.makeConstraints { make in
            //make.top.equalTo(themeCollectionView.snp.bottom)
            make.top.equalTo(movieLabel.snp.bottom)
            
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            
        }
    }
    
    
    func apiRequest(theme: theme = .popular) {
        NetworkManager.shared.loadMovie(theme: theme) { result in
            self.movieData = result
            self.movieTableView.reloadData()
        }
    }
    
    func animateLabel() {
        UIView.animate(withDuration: 1) {
            self.movieLabel.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.7) {
                self.movieLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            } completion: { _ in
                UIView.animate(withDuration: 1, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, animations: {
                    self.movieLabel.snp.remakeConstraints { make in
                        make.top.equalTo(self.view.safeAreaLayoutGuide)
                        make.centerX.equalTo(self.view.safeAreaLayoutGuide)
                    }
                    self.view.layoutIfNeeded()
                    self.movieLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                }) { _ in
                    self.themeLabel.alpha = 1
                    self.themeCollectionView.alpha = 1
                    self.movieTableView.alpha = 1
                    
                }
            }
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "movie", for: indexPath) as! MovieTableViewCell
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
            let videoID = result.first(where: { $0.type == "Trailer" }) ?? result.first!
            movieDetailViewController.playerView.load(withVideoId: videoID.key)
            self.navigationController?.pushViewController(movieDetailViewController, animated: true)
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = themeCollectionView.dequeueReusableCell(withReuseIdentifier: "theme", for: indexPath) as! ThemeCollectionViewCell
        let theme = themes[indexPath.row]
        cell.label.text = theme
        
        let defaultSelectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: defaultSelectedIndexPath, animated: false, scrollPosition: .top)
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: defaultSelectedIndexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let themeName: theme
        switch themes[indexPath.row] {
        case "Popular":
            themeName = .popular
        case "Now playing":
            themeName = .nowPlaying
        case "Upcoming":
            themeName = .upcoming
        case "Top Rated":
            themeName = .topRated
        default:
            themeName = .nowPlaying
        }
        
        apiRequest(theme: themeName)

        
        
    }
    
    
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        let theme = themes[indexPath.row]
        label.text = theme
        label.sizeToFit()
        return CGSize(width: label.frame.width + 2, height: 30)
    }
}




