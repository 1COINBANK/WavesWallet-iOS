//
//  ApplicationVersionRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30/05/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol ApplicationVersionRepositoryProtocol {
    func version() -> Observable<String>
}
