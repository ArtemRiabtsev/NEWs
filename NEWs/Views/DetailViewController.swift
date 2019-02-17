//
//  DetailViewController.swift
//  NEWs
//
//  Created by imac on 2/13/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//

private let reuseIdentifier = "defaultCell"

import UIKit

class DetailViewController: UITableViewController {
    var presenter: PresenterProtocol?
    var type: RequestType?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        if presenter?.detailDataSource == nil {
            self.tableView.refreshControl?.beginRefreshing()
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.presenter?.detailDataSource != nil {
            DispatchQueue.main.async {
                tableView.refreshControl?.endRefreshing()
            }
        }
        return presenter?.detailDataSource?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        presenter?.configureDetail(cell, row: indexPath.row)

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter?.currentRequest = type
        self.presenter?.getRequestParam(index: indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
}

