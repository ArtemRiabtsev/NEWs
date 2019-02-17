//
//  NewPresenter.swift
//  NEWs
//
//  Created by Артем Рябцев on 2/11/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//

import UIKit

protocol ViewProtocol: class {
    func showErrorMessage(message: String)
    func newsDataDidLoad()
    func pushDetail(_ viewController: DetailViewController)
}

class NewsPresenter {
    var sourses: [Sources]? {
        didSet {
            self.detailDataSource = getNamesFromSources()
        }
    }
    var detailDataSource: [String]?
    
    var newsData:[Article]? {
        didSet {
            if let news = newsData  {
                if news.isEmpty {
                    self.interface?.showErrorMessage(message: "News not found!")
                    self.currentRequest = .news
                } else {
                    self.interface?.newsDataDidLoad()
                }
            }
        }
    }
    var currentRequest: RequestType? {
        didSet {
            self.pageNumber = 1
            self.newsData = nil
        }
    }
    var requestParam: String?
    var pageNumber: Int {
        didSet {
            print("Curent page = ",pageNumber)
        }
    }
    weak var interface: ViewProtocol?
    let downloadingQueue: OperationQueue
    let client: NewsClient
    init(view: ViewProtocol) {
        interface = view
        client = NewsClient()
        downloadingQueue = OperationQueue()
        pageNumber = 1
        currentRequest = .news
    }
    private func downloadImage(path: String, complition: @escaping (String?, UIImage?) -> Void) {
        let operation = DownloadOperation(path: path)
        operation.completionBlock = {
            if let error = operation.resultError {
                print("ERROR: ", error)
                complition(error, nil)
            }
            if let img = operation.image {
                complition(nil, img)
            }
        }
        downloadingQueue.addOperation(operation)
    }
    private func countryList() -> [String] {
        var countries: [String] = []
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
        return countries
    }
    private func getNamesFromSources() -> [String] {
        var names = [String]()
        if let sources = self.sourses {
            for source in sources {
                names.append(source.name)
            }
        }
        return names
    }
    private func locale(for fullCountryName : String) -> String {
        let locales : String = ""
        for localeCode in NSLocale.isoCountryCodes {
            let identifier = NSLocale(localeIdentifier: "en_UK")
            let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
            guard let name = countryName?.lowercased() else { return ""}
            if fullCountryName.lowercased() == name {
                return localeCode.lowercased()
            }
        }
        return locales.lowercased()
    }
    private func newsByCountry() {
        guard let param = requestParam else { return }
        let request = NewsEndpoint.newsByCountry(clientID: NewsClient.apiKey, countryCode: param, page: pageNumber)
        client.getNewsByCountry(endpoint: request) {[weak self] either in
            guard let strongSelf = self else { return }
            switch either {
            case .success(let result):
                if let data = strongSelf.newsData {
                    strongSelf.newsData = data + result.articles
                } else {
                    strongSelf.newsData = result.articles
                }
                strongSelf.pageNumber = strongSelf.pageNumber + 1
            case .error(let error):
                strongSelf.interface?.showErrorMessage(message: error.localizedDescription)
            }
        }
    }
    private func newsByCategory() {
        guard let param = requestParam else { return }
        let request = NewsEndpoint.newsByCategory(clientID: NewsClient.apiKey, category: param, page: pageNumber)
        client.getNewsByCountry(endpoint: request) {[weak self] either in
            guard let strongSelf = self else { return }
            switch either {
            case .success(let result):
                if let data = strongSelf.newsData {
                    strongSelf.newsData = data + result.articles
                } else {
                    strongSelf.newsData = result.articles
                }
                strongSelf.pageNumber = strongSelf.pageNumber + 1
            case .error(let error):
                strongSelf.interface?.showErrorMessage(message: error.localizedDescription)
            }
        }
    }
    private func newsBySource() {
        guard let param = requestParam else { return }
        let request = NewsEndpoint.newsBySource(clientID: NewsClient.apiKey, source: param, page: pageNumber)
        client.getNewsByCountry(endpoint: request) {[weak self] either in
            guard let strongSelf = self else { return }
            switch either {
            case .success(let result):
                if let data = strongSelf.newsData {
                    strongSelf.newsData = data + result.articles
                } else {
                    strongSelf.newsData = result.articles
                }
                strongSelf.pageNumber = strongSelf.pageNumber + 1
            case .error(let error):
                strongSelf.interface?.showErrorMessage(message: error.localizedDescription)
            }
        }
    }
}
//MARK: - - - - - PresenterProtocol

extension NewsPresenter: PresenterProtocol {
    func getUrl(index: Int) -> String {
        if let article = newsData?[index], let url = article.url {
            return url
        }
        interface?.showErrorMessage(message: "Can't open news")
        return ""
    }
    func search(by string: String) {
        currentRequest = .search
        requestParam = string.lowercased()
        guard let query = requestParam else { return }
        let endpoint = NewsEndpoint.search(clientID: NewsClient.apiKey, query: query, page: pageNumber)
        client.getNews(endpoint: endpoint) {[weak self] either in
            guard let strongSelf = self else { return }
            switch either {
            case .success(let result):
                if let data = strongSelf.newsData {
                    strongSelf.newsData = data + result.articles
                } else {
                    strongSelf.newsData = result.articles
                }
                strongSelf.pageNumber = strongSelf.pageNumber + 1
            case .error(let error):
                strongSelf.interface?.showErrorMessage(message: error.localizedDescription)
            }
        }
    }
    func getRequestParam(index: Int) {
        guard let request = currentRequest else {return }
        switch request {
        case .news, .search:
            return
        case .country:
            guard let country = self.detailDataSource?[index] else { return }
            requestParam = locale(for: country)
            newsByCountry()
        case .category:
            requestParam  = self.detailDataSource?[index].lowercased()
            newsByCategory()
        case .source:
            let source = sourses?[index]
            requestParam  = source?.id
            newsBySource()
        }
    }
    func refreshNews(_ flag: Bool) {
        if !flag {
            pageNumber = 1
            newsData = nil
        }
        guard let request = currentRequest else {
            return
        }
        guard let query = requestParam else { return }
        switch request {
        case .news:
            fetchNews()
        case .search:
            search(by: query)
        case .country:
            newsByCountry()
        case .category:
            newsByCategory()
        case .source:
            print("Hi")
        }
    }
    
    func menuButtonTapped(with tag: Int) {
        self.detailDataSource = nil
        switch tag {
        case 0:
            self.detailDataSource = Categories.list
            let detailVC = createDetailController()
            detailVC.type = RequestType.category
            interface?.pushDetail(detailVC)
        case 1:
            self.detailDataSource = countryList()
            let detailVC = createDetailController()
            detailVC.type = RequestType.country
            interface?.pushDetail(detailVC)
        case 2:
            let endpoint = NewsEndpoint.sources(clientID: NewsClient.apiKey)
            let detailVC = self.createDetailController()
            detailVC.type = RequestType.source
            self.interface?.pushDetail(detailVC)
            client.getSources(endpoint: endpoint) { [weak self] either in
                guard let strongSelf = self else { return }
                switch either {
                case .success(let result):
                    strongSelf.sourses = result.sources
                    detailVC.tableView.reloadData()
                case .error(let error):
                    strongSelf.interface?.showErrorMessage(message: error.localizedDescription)
                }
            }
        default:
            return
        }
    }
    
    func createDetailController() -> DetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: String(describing: DetailViewController.self)) as? DetailViewController {
            detailVC.presenter = self
            return detailVC
        } else {
            return DetailViewController()
        }
    }
    
    func configureDetail(_ cell: UITableViewCell, row: Int) {
        let str = self.detailDataSource?[row]
        cell.textLabel?.text = str
    }
    func configure(_ cell: NewsCell, row: Int) {
        guard let data = newsData else { return }
        let article = data[row] as Article
        
        DispatchQueue.main.async {
            cell.autorLbl.text = article.author
            cell.sourceLbl.text = article.source?.name
            cell.titleLbl.text = article.title
            cell.descriptionLbl.text = article.description
        }
        guard let path = article.urlToImage else {
            print("Image url exist")
            return }
        downloadImage(path: path) { (errorMessage, image) in
            if let img = image {
                DispatchQueue.main.async {
                    cell.mainImg.image = img
                    cell.spinner.stopAnimating()
                }
            }
        }
    }
    func fetchNews() {
        let endpoint = NewsEndpoint.news(clientID: NewsClient.apiKey, page: self.pageNumber)
        if pageNumber > 10 {
            self.interface?.showErrorMessage(message: "This is all news")
        }
        client.getNews(endpoint: endpoint) {[weak self] either in
            guard let strongSelf = self else { return }
            switch either {
            case .success(let result):
                if let data = strongSelf.newsData {
                    strongSelf.newsData = data + result.articles
                } else {
                    strongSelf.newsData = result.articles
                }
                strongSelf.pageNumber = strongSelf.pageNumber + 1
            case .error(let error):
                strongSelf.interface?.showErrorMessage(message: error.localizedDescription)
            }
        }
    }
}

enum RequestType {
    case news
    case search
    case country
    case category
    case source
}
