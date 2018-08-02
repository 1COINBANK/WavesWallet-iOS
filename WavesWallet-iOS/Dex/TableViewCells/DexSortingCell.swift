//
//  DexSortingCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol DexSortingCellDelegate: AnyObject {

    
}

final class DexSortingCell: UITableViewCell, Reusable {

    
    weak var delegate : DexSortingCellDelegate?
    
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

}
