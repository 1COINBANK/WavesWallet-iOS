//
//  AssetViewPresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AsssetPresenterProtocol {
    typealias Feedback = (Driver<AssetTypes.DisplayState>) -> Signal<AssetTypes.DisplayEvent>
    var interactor: AssetsInteractorProtocol! { get set }
    func system(feedbacks: [Feedback])
}

