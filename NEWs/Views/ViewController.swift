//
//  ViewController.swift
//  NEWs
//
//  Created by Артем Рябцев on 2/10/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//
import UIKit
import SafariServices

protocol PresenterProtocol: class {
    var newsData:[Article]? { get }
    var currentRequest: RequestType? { get set }
    func configure(_ cell: NewsCell, row: Int)
    func configureDetail(_ cell: UITableViewCell, row: Int)
    func fetchNews()
    func getUrl(index: Int) -> String
    func menuButtonTapped(with tag: Int)
    func createDetailController() -> DetailViewController
    var detailDataSource: [String]? { get set }
    func refreshNews(_ flag: Bool)
    func getRequestParam(index: Int)
    func search(by string: String)
}

class ViewController: UIViewController {
    private var loadingInProgress = true {
        didSet {
            print("loadingInProgress = ",loadingInProgress)
        }
    }
    private let refreshControl = UIRefreshControl()
    private var menuIsOpen = false
    private var presenter: PresenterProtocol?
    @IBOutlet private weak var menuConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.showsCancelButton = true
        self.searchBar.placeholder = "enter keyword..."
        self.searchBar.delegate = self
        self.searchBar.spellCheckingType = .yes
        self.searchBar.autocorrectionType = .yes
        presenter = NewsPresenter(view: self)
        presenter?.fetchNews()
        let newsCell =  UINib(nibName: String(describing: NewsCell.self), bundle: Bundle.main)
        tableView.register(newsCell, forCellReuseIdentifier: NewsCell.cellId)
        refreshControl.addTarget(self, action: #selector(refreshNews(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        tableView.refreshControl?.beginRefreshing()
    }
    //MARK: - - - - Actions
    @objc private func refreshNews(_ sender: Any) {
        presenter?.refreshNews(false)
    }
    @IBAction private  func menuButtonsAction(_ sender: UIButton) {
        presenter?.menuButtonTapped(with: sender.tag)
    }
    @IBAction private  func searchAction(_ sender: Any) {
        self.view.layoutIfNeeded()
        menuIsOpen = !menuIsOpen
        menuConstraint.constant = menuIsOpen ? 80 : 0
        UIView.animate(withDuration: 0.33, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableView.refreshControl?.beginRefreshing()
        if let query = searchBar.text, query != "" {
            presenter?.search(by: query)
        }
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.currentRequest = .news
        presenter?.fetchNews()
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return presenter?.newsData?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = self.view.frame.height / 7
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.cellId, for: indexPath) as? NewsCell else {
            return UITableViewCell()
        }
        cell.spinner.startAnimating()
        self.presenter?.configure(cell, row: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let path = presenter?.getUrl(index: indexPath.row) else { return }
        if let url = URL(string: path) {
            if #available(iOS 11.0, *) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true)
            } else {
                print("Fallback on earlier versions")
            }
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let data = self.presenter?.newsData else {return}
        if indexPath.row == data.count - 1 && !loadingInProgress {
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
            loadingInProgress = true
            self.presenter?.refreshNews(true)
        } else {
            return
        }
    }

}
extension ViewController: ViewProtocol {
    func pushDetail(_ viewController: DetailViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func showErrorMessage(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
            let close = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alert.addAction(close)
            strongSelf.present(alert, animated: true, completion: nil)
        }
    }
    func newsDataDidLoad() {
        DispatchQueue.main.async {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView.tableFooterView?.isHidden = true
            strongSelf.tableView.reloadData()
            strongSelf.tableView.layoutIfNeeded()
            strongSelf.refreshControl.endRefreshing()
            strongSelf.loadingInProgress = false
        }
    }
}
