//
//  LastTradesRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDKServices

final class LastTradesRepositoryRemote: LastTradesRepositoryProtocol {

    private let transactionsDataService = ServicesFactory.shared.transactionsDataService
    
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }
    
    func lastTrades(accountAddress: String,
                    amountAsset: DomainLayer.DTO.Dex.Asset,
                    priceAsset: DomainLayer.DTO.Dex.Asset,
                    limit: Int) -> Observable<[DomainLayer.DTO.Dex.LastTrade]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Dex.LastTrade]>  in
                guard let self = self else { return Observable.empty() }
                             
                let query = DataService.Query.ExchangeFilters(matcher: nil,
                                                              sender: nil,
                                                              timeStart: nil,
                                                              timeEnd: nil,
                                                              amountAsset: amountAsset.id,
                                                              priceAsset: priceAsset.id,
                                                              after: nil,
                                                              limit: limit)
                
                return self
                    .transactionsDataService
                    .exchangeFilters(query: query,
                                     enviroment: environment.environmentServiceData)
                    .flatMap({ (transactions) -> Observable<[DomainLayer.DTO.Dex.LastTrade]> in
                        
                        var trades: [DomainLayer.DTO.Dex.LastTrade] = []
                        for tx in transactions {
                            
                            let sum = Money(value: Decimal(tx.price * tx.amount), priceAsset.decimals)
                            let orderType: DomainLayer.DTO.Dex.OrderType = tx.orderType == .sell ? .sell : .buy
                            
                            let model = DomainLayer.DTO.Dex.LastTrade(time: tx.timestamp,
                                                                      price: Money(value: Decimal(tx.price), priceAsset.decimals),
                                                                      amount: Money(value: Decimal(tx.amount), amountAsset.decimals),
                                                                      sum: sum,
                                                                      type: orderType)
                            trades.append(model)
                        }
                        
                        return Observable.just(trades)
                    })
            })
    }
}
