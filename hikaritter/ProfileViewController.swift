//
//  ProfileViewController.swift
//  hikaritter
//
//  Created by 兎澤佑 on 2015/04/10.
//  Copyright (c) 2015年 兎澤 佑. All rights reserved.
//

import UIKit
import TwitterKit

class ProfileViewController: UIViewController {
    var myAccount: TWTRUser!
    var icon: UIImageView!
    var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タイトル
        self.title = "アカウント"
        
        // プロフィール情報取得
        Twitter.sharedInstance().APIClient.loadUserWithID(Twitter.sharedInstance().session().userID) {
            (user, error) -> Void in
            self.myAccount = user
            println(user.userID)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
