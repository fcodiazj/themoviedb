//
//  ViewController.swift
//  TheMovieDB
//
//  Created by Fransico D. on 2/21/19.
//  Copyright © 2019 innomar.cl. All rights reserved.
//

import Alamofire
import AlamofireImage
import Bottomsheet
import Refreshable
import UIKit

class MovieViewController: UIViewController {
    // MARK: - Movie Variables Store

    //This variable keeps the api pager response.
    var pageAt: Int = 0

    var dataStore: [MovieResult] = [] {
        //everytime the data changes, we refresh the table
        didSet {
            self.moviesTableView.reloadData()
        }
    }
    // MARK: - Outlets

    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var moviesTableView: UITableView!

    // MARK: - Details Movies Outlets
    /// this is the placeholder view, to display the movies details
    @IBOutlet var movieDetailView: UIView!
    //title, detail, and image of the movie
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDetail: UITextView!
    @IBOutlet weak var movieImage: UIImageView!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        //Start fetching the first data from the cloud.
        fetchNetworkPopular()

        //Setup pull to refresh, when last item is reached, we reload with more data
        moviesTableView.addLoadMore { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.moviesTableView.stopLoadMore()
                self?.pullToRefreshFetchMoreNetworkData()
            }
        }
    }

    // MARK: - Actions

    /// this method captures everytime the segmented is changed.
    /// when changed we find its type and called popular or topRated.
    ///
    /// - Parameter sender: the segmented movie
    @IBAction func categoryChanged(_ sender: Any) {
        let selected = ApiNetworkType(rawValue: categorySegment.selectedSegmentIndex) ?? .popular

        pageAt = 0
        dataStore = []

        switch selected {
        case .popular:
            fetchNetworkPopular()
        case .topRated:
            fetchNetworkRated()
        }
    }

    // MARK: - Utilties

    /// this method scrolls the last table item table to top, after the new data was loaded.
    func scrollToNextReloadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let savedIndex = self.moviesTableView.indexPathsForVisibleRows?.last {
                self.moviesTableView.scrollToRow(at: savedIndex, at: .top, animated: true)
            }
        }
    }

    /// this method will pull more data from the network
    func pullToRefreshFetchMoreNetworkData() {
        let selected = ApiNetworkType(rawValue: categorySegment.selectedSegmentIndex) ?? .popular

        switch selected {
        case .popular:
            ApiClient.fetchEndpoint(route: APIRouter.popular(page: pageAt + 1)) { networkResponse, code in
                guard let list = networkResponse?.results, code == 0 else {
                    return
                }
                self.pageAt = networkResponse?.page ?? 1
                self.dataStore.append(contentsOf: list)
                self.scrollToNextReloadData()
            }
        case .topRated:
            ApiClient.fetchEndpoint(route: APIRouter.topRated(page: pageAt + 1)) { networkResponse, code in
                guard let list = networkResponse?.results, code == 0 else {
                    return
                }
                self.pageAt = networkResponse?.page ?? 1
                self.dataStore.append(contentsOf: list)
                self.scrollToNextReloadData()
            }
        }
    }

    /// find popular movies and reload the table
    func fetchNetworkPopular() {
        ApiClient.fetchEndpoint(route: APIRouter.popular(page: pageAt + 1)) { networkResponse, code in
            guard let list = networkResponse?.results, code == 0 else {
                return
            }
            self.pageAt = networkResponse?.page ?? 1
            self.dataStore = list
        }
    }

    /// find top rated movies and reload the table
    func fetchNetworkRated() {
        ApiClient.fetchEndpoint(route: APIRouter.topRated(page: pageAt + 1)) { networkResponse, code in
            guard let list = networkResponse?.results, code == 0 else {
                return
            }
            self.pageAt = networkResponse?.page ?? 1
            self.dataStore = list
        }
    }

    /// Find an image from the internet, an set it on the detail
    /// it will also cache the image thanks to extension alamofire image
    /// we set transport secuirty to "YES" to allow http protocol to work on the info.plist
    ///
    /// - Parameter path: the endpoint path of the image
    func fetchImage(path: String) {
        //TODO: the idea is to use ApiRouter to build this url. but poinst to another
        //unsecure endpoint. so i just leave it raw for now.
        let baseUrl = "http://image.tmdb.org/t/p/w500/" + path
        Alamofire.request(baseUrl).responseImage { response in
            guard let image = response.result.value else {
                return
            }
            UIView.transition(
                with: self.movieImage,
                duration: 0.75,
                options: .transitionCrossDissolve,
                animations: {
                    self.movieImage.image = image
                },
                completion: nil
            )
        }
    }

    // MARK: - Constructors Controllers

    /// this method will create the bottom message that will be use
    /// to display the movie detail.
    ///
    /// - Returns: Bottomsheet.Controller aka UIViewController
    func createBottomMessage() -> UIViewController {
        let controller = Bottomsheet.Controller()
        movieImage.image = UIImage(named: "PlaceHolder")
        controller.addContentsView(movieDetailView)
        // customize
        controller.overlayBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        controller.viewActionType = .tappedDismiss
        controller.initializeHeight = view.frame.size.height * 0.75
        return controller
    }
}

// MARK: - Delegate
extension MovieViewController: UITableViewDelegate {

    /// Did tap on cell
    ///
    /// - Parameters:
    ///   - tableView: movie tableview
    ///   - indexPath: cell tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = dataStore[indexPath.row]
        movieTitle.text = item.title
        movieDetail.text = item.overview

        let bottomController = createBottomMessage()

        //display the bottom message
        DispatchQueue.main.async {
            self.present(bottomController, animated: true) {
                    self.fetchImage(path: item.posterPath)
            }
        }
    }
}
// MARK: - DataSource
extension MovieViewController: UITableViewDataSource {
    /// this method returns the total of rows founded
    ///
    /// - Parameters:
    ///   - tableView: table
    ///   - section: section tapped
    /// - Returns: returns the count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.count
    }

    /// this method configures the cell with data from the datasource
    ///
    /// - Parameters:
    ///   - tableView: table
    ///   - indexPath: the index
    /// - Returns: the cell configured.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") else {
            assertionFailure("cant load myCell")
            return UITableViewCell()
        }

        let movieResult: MovieResult = dataStore[indexPath.row]
        cell.textLabel?.text = movieResult.title

        return cell
    }
}
