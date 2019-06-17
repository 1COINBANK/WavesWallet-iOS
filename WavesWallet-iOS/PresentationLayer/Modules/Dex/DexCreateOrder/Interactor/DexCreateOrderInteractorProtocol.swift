//
//  DexCreateOrderInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

protocol DexCreateOrderInteractorProtocol {
    func createOrder(order: DexCreateOrder.DTO.Order) -> Observable<ResponseType<DexCreateOrder.DTO.Output>>
    func getFee(amountAsset: String, priceAsset: String) -> Observable<Money>
}
