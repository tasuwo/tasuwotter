//
//  ViewController.swift
//  hikaritter
//
//  Created by 兎澤佑 on 2015/03/31.
//  Copyright (c) 2015年 兎澤 佑. All rights reserved.
//

import UIKit
import TwitterKit


/**
 * ログイン画面
 */
class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ログインボタン作成
        let logInButton = TWTRLogInButton(logInCompletion:
            { (session, error) in
                if (session != nil) {
                    println("signed in as \(session.userName)");
                    
                    // viewController 用意
                    let tabbarVC = MainTabBarController()
                    
                    // ウインドウに root View Controller 割り当て
                    UIApplication.sharedApplication().keyWindow?.rootViewController = tabbarVC
                    
                } else {
                    println("error: \(error.localizedDescription)");
                }
        })
        
        // ログインボタン配置
        logInButton.center = self.view.center
        
        // ログインボタン表示
        self.view.addSubview(logInButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

