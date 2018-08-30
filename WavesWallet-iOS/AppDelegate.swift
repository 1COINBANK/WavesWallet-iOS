//
//  AppDelegate.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Gloss
import IQKeyboardManagerSwift
import RESideMenu
import RxSwift
import SVProgressHUD
import UIKit
import Moya
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UserDefaults.standard.set(true, forKey: "isTestEnvironment")
        UserDefaults.standard.synchronize()

        Swizzle(initializers: [UIView.passtroughInit,
                               UIView.roundedInit,
                               UIView.shadowInit]).start()

        SweetLogger.current.visibleLevels = [.debug, .network, .error]

        self.window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared.enable = true
        SVProgressHUD.setOffsetFromCenter(UIOffsetMake(0, 40))
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.clear)
        UIBarButtonItem.appearance().tintColor = UIColor.black

        self.showStartController()

        self.window?.makeKeyAndVisible()

//        test.rx.request(.list(accountAddress: "3N9yFERJHAg921W7Soamj5R8NydMpZmCR8t", limit: 10000)).subscribe(onSuccess: { (response) in
//            let container = try? response.map(Node.DTO.TransactionContainers.self)
//
//        }, onError: nil)
//
//        JSONDecoder.decode(type: Node.DTO.TransactionContainers.self, json: "AllTransactionExample").subscribe()

//        do {
//            let bd = try? Realm()
//
//            let txMain = MassTransferTransaction()
//
//            let tx = MassTransferTransaction.Transfer()
//            tx.recipient = "Anal"
//            txMain.transfers.append(tx)
//
//            try? bd?.write {
//                bd?.add(txMain, update: true)
//            }
//        } catch let e {
//            print(e)
//        }


        return true
    }

    func showStartController() {
        self.window?.backgroundColor = AppColors.wavesColor
        let realm = WalletManager.getWalletsRealm()
        let w = realm.objects(WalletItem.self).filter("isLoggedIn == true")
        if w.count > 0 {
            WalletManager.didLogin(toWallet: w[0])
        } else {
            self.window!.rootViewController = StoryboardManager.launchViewController()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        WalletManager.clearPrivateMemoryKey()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let urlScheme = url.scheme, urlScheme == "waves" {
            OpenUrlManager.openUrl = url
            return true
        } else {
            return false
        }
    }

    class func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var menuController: RESideMenu {
        return self.window?.rootViewController as! RESideMenu
    }
}

// TODO: Remove
extension AppDelegate: AssetModuleOutput {

}
