//
//  UIViewController+Additionals.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let smallNavBarHeight: CGFloat = 44
    static let bigNavBarHeight: CGFloat = 96
}

extension UIViewController {

   


    

 
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    func hideTopBarLine() {
        navigationItem.shadowImage = UIImage()
    }

 
    
    var isShowNotFullBigNavigationBar: Bool {
        return navigationController?.navigationBar.frame.size.height.rounded(.down) ?? 0 < Constants.bigNavBarHeight
    }

    var isSmallNavigationBar: Bool {
        return navigationController?.navigationBar.frame.size.height.rounded(.down) ?? 0 <= Constants.smallNavBarHeight
    }

   
    
    func setupSmallNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationItem.prefersLargeTitles = false
        }
    }
    
    func setupBigNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationItem.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .automatic
        }
    }

   
    
    static var cleanShadowImage: UIImage = {
        return UIImage()
    }()
    
    func tableViewTopOffsetForBigNavBar(_ tableView: UITableView) -> CGPoint {
        
        //TODO: check if IOS 10 will be support
        let navBarY = (navigationController?.navigationBar.frame.origin.y ?? 0)
        let offset = -(Constants.bigNavBarHeight + navBarY + tableView.contentInset.top)
        return CGPoint(x: 0, y: offset)
    }
}
