//
//  MainTabBarController.swift
//  hikaritter
//
//  Created by 兎澤佑 on 2015/04/09.
//  Copyright (c) 2015年 兎澤 佑. All rights reserved.
//

import UIKit
import TwitterKit


class MainTabBarController: UITabBarController {
    
    // API
    let api = TwitterAPI.sharedInstance
    
    // 各 View Controller
    var homeTLview:    TimelineViewController!
    var mentionTLview: TimelineViewController!
    //var profileview:   ProfileViewController!
        
    // 各 Navigation Controller
    var homeTLNC:    UINavigationController?
    var mentionTLNC: UINavigationController?
    //var profileNC:   UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // viewController 用意
        homeTLview    = TimelineViewController(title: "ホーム", mode: api.HOME)
        mentionTLview = TimelineViewController(title: "通知", mode: api.MENTION)
        //profileview   = ProfileViewController()
        
        // ナビゲーションバー用意
        self.homeTLNC    = UINavigationController(rootViewController: homeTLview)
        self.mentionTLNC = UINavigationController(rootViewController: mentionTLview)
        //self.profileNC   = UINavigationController(rootViewController: profileview)
        
        //表示するtabItemを指定（今回はデフォルトのItemを使用）
        homeTLview.tabBarItem    = UITabBarItem(title: "ホーム", image: UIImage(named: "home"), tag: 0)
        mentionTLview.tabBarItem = UITabBarItem(title: "通知", image: UIImage(named: "bell"), tag: 1)
        //profileview.tabBarItem   = UITabBarItem(title: "アカウント", image: UIImage(named: "account"), tag: 2)
        
        // タブで表示するViewControllerを配列に格納
        let myTabs : [AnyObject] = [homeTLNC!, mentionTLNC!]
        /*, profileNC!*/
        
        // 配列をTabにセット
        self.setViewControllers(myTabs, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}