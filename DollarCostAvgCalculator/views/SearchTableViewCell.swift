//
//  SearchTableViewCell.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/24/22.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetSymbolLabel: UILabel!
    @IBOutlet weak var assetTypeLabel: UILabel!

    func configure(with item: SearchResultItem) {
        assetNameLabel.text =  item.name
        assetSymbolLabel.text =  item.symbol
        assetTypeLabel.text =  "\(item.type)  \(item.currency)"
        
    }
}
