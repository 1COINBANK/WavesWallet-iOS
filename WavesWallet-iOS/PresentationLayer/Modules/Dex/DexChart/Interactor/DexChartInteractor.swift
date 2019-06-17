//
//  DexChartInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private enum Constants {
    static let timeStart = "timeStart"
    static let timeEnd = "timeEnd"
    static let interval = "interval"
}

final class DexChartInteractor: DexChartInteractorProtocol {
    
    private let candlesReposotiry = FactoryInteractors.instance.repositories.candlesRepository
    private let auth = FactoryInteractors.instance.authorization
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func candles(timeFrame: DomainLayer.DTO.Candle.TimeFrameType, timeStart: Date, timeEnd: Date) -> Observable<[DomainLayer.DTO.Candle]> {
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.Candle]> in
            guard let self = self else { return Observable.empty() }
            return self.candlesReposotiry.candles(accountAddress: wallet.address,
                                                   amountAsset: self.pair.amountAsset.id,
                                                   priceAsset: self.pair.priceAsset.id,
                                                   timeStart: timeStart,
                                                   timeEnd: timeEnd,
                                                   timeFrame: timeFrame)
                .catchError({ (error) -> Observable<[DomainLayer.DTO.Candle]> in
                    return Observable.just([])
                })
        })
    }
}
