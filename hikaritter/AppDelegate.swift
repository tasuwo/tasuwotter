//
//  AppDelegate.swift
//  hikaritter
//
//  Created by 兎澤佑 on 2015/03/31.
//  Copyright (c) 2015年 兎澤 佑. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // 利用するSDKのセット
        // Twitter SDKを用いる
        Fabric.with([Twitter()])
        
        // View Controller 用意
        let myFirstVC: LoginViewController = LoginViewController()
        
        // ウインドウを用意
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // ウインドウに rootviewcontroller を割り当て
        self.window?.rootViewController = myFirstVC
        
        // ウインドウ表示
        self.window?.makeKeyAndVisible()
        
        
        return true
    }
}

