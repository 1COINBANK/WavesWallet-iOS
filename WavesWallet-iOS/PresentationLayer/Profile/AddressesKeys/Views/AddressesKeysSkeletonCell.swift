//
//  AddressesKeysSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 60
}

final class AddressesKeysSkeletonCell: SkeletonCell, Reusable {

    @IBOutlet var viewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: ViewCalculateHeight

extension AddressesKeysSkeletonCell: ViewCalculateHeight {

    static func viewHeight(model: Void, width: CGFloat) -> CGFloat {
        return Constants.height
    }
}
