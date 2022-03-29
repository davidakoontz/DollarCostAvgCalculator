//
//  ViewController.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/23/22.
//

import UIKit
import Combine
import MBProgressHUD

class SearchTableViewController: UITableViewController, UIAnimatable {

    private enum Mode {
        case onboarding
        case search
    }
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    private let avService = AVService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: SearchResults?
    @Published private var  mode: Mode = .onboarding
    @Published private var searchQuery = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBar()
        observeForm()
        //performSearch()
    }
    
    private func  setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.title =  "Search"
    }
    
    private func observeForm() {
        $searchQuery.debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                self.showLoadingAnimation()
                self.avService.fetchSymbolsPublisher(keywords: searchQuery).sink { (completion) in
                    self.hideLoadingAnimation()
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished: break
                    }
                } receiveValue: { (searchResults) in
                    self.searchResults = searchResults
                    self.tableView.reloadData()
                    //print(searchResults)
                } .store(in: &self.subscribers)
            }.store(in: &subscribers)

        $mode.sink { [unowned self]  (mode) in
            switch mode {
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceholderView()
            case .search:
                self.tableView.backgroundView = nil
            }
        }.store(in: &subscribers)
    
    }
    
//    private func performSearch() {
//        avService.fetchSymbolsPublisher(keywords: "IBM").sink { (completion) in
//            switch completion {
//            case .failure(let error):
//                print(error.localizedDescription)
//            case .finished: break
//            }
//        } receiveValue: { (searchResults) in
//            self.searchResults = searchResults
//            print(searchResults)
//        } .store(in: &subscribers)
//    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.items.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell97", for: indexPath) as! SearchTableViewCell
        if let searchResults = searchResults {
            let items =  searchResults.items[indexPath.row]
            cell.configure(with: items)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let searchResults = self.searchResults {
           
            let item = searchResults.items[indexPath.item]
            let symbol = item.symbol
            handleSelection(for: symbol, item: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private  func handleSelection(for symbol: String, item: SearchResultItem) {
        showLoadingAnimation()
        avService.fetchTimeSeriesMonthlyAdjustedPublisher(keywords: symbol).sink { [weak self] (completionResult) in
            self?.hideLoadingAnimation()
            switch completionResult {
            case .failure(let error):
                print(error)
            case .finished:  break
            }
        } receiveValue: { [weak self] (timeSeriesMonthlyAdjusted) in
            self?.hideLoadingAnimation()
            let asset =  Asset(searchResultItem: item, timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
            self?.performSegue(withIdentifier: "showCalculator", sender: asset)
            //print("success: \(timeSeriesMonthlyAdjusted)")
        }.store(in: &subscribers)

    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalculator",
           let destination = segue.destination as? CalculatorTableViewController,
           let asset =  sender as? Asset  {
                destination.asset = asset       //  the Company or ETF Info
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        // remove Optionality of querry string
        guard  let searchBarTxt = searchController.searchBar.text, !searchBarTxt.isEmpty else { return }
        self.searchQuery = searchBarTxt
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
}

