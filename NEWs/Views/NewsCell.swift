//
//  NewsCell.swift
//  NEWs
//
//  Created by Артем Рябцев on 2/11/19.
//  Copyright © 2019 Артем Рябцев. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    static let cellId = "NewsCell"
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var sourceLbl: UILabel!
    @IBOutlet weak var autorLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImg.image = nil
//        spinner.startAnimating()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
