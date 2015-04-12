//
//  SingleTweetViewController.swift
//  hikaritter
//
//  Created by 兎澤佑 on 2015/04/12.
//  Copyright (c) 2015年 兎澤 佑. All rights reserved.
//

import UIKit
import TwitterKit

class SingleTweetViewController: UIViewController {
    var tweet: TWTRTweet!
    var tweetView: TWTRTweetView!
    var fav: Int64!
    var rt: Int64!
    
    init(tweet: TWTRTweet){
        super.init(nibName: nil, bundle: nil)
        self.tweet = tweet
        self.fav   = tweet.favoriteCount
        self.rt    = tweet.retweetCount
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tweetView = TWTRTweetView(tweet: self.tweet, style: TWTRTweetViewStyle.Compact)
        self.tweetView.center = self.view.center
        self.view.addSubview(self.tweetView)
    }
}
