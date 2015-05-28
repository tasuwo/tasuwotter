//
//  TwitterAPI.swift
//  hikaritter
//
//  Created by 兎澤佑 on 2015/04/03.
//  Copyright (c) 2015年 兎澤 佑. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterAPI {
    // Twitter API 用
    let baseURL = "https://api.twitter.com"
    let version = "/1.1"
    // 記号
    let INIT = 0
    let UP   = 1
    let DOWN = 2
    // タイムライン
    let HOME    = 0
    let MENTION = 1
    
    var max_id = ""
    var since_id = ""
    
    
    init() {
        
    }
    
    /**
     * シングルトン
     */
    class var sharedInstance : TwitterAPI {
        struct Static {
            static let instance : TwitterAPI = TwitterAPI()
        }
        return Static.instance
    }
    
    /**
     * タイムラインの取得
     */
    class func getTimeline(mode: Int, direction: Int, tweets: [TWTRTweet]->(), error: (NSError)->()) {
        // REST API の指定(タイムラインの取得)
        let api = self.sharedInstance
        var path = "/statuses/"
        switch mode {
        case api.HOME:
            path += "home_timeline.json"
        case api.MENTION:
            path += "mentions_timeline.json"
        default:
            println("Error: api error")
        }
        let endpoint = api.baseURL + api.version + path
        // エラー設定
        var clientError: NSError?
        var params: [NSObject : AnyObject]?
        
        // パラメータ設定
        switch direction {
        case api.INIT:
            // 初期の読み込み
            params = nil
        case api.UP:
            // 上部更新
            params = ["since_id": api.since_id]
            println("up")
        case api.DOWN:
            // 下部更新
            params = ["max_id": api.max_id]
            println("down")
        default:
            println("Error: param diff")
        }
        
        // NSURLRequest を生成
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET",
            URL: endpoint,
            parameters: params,
            error: &clientError
        )
        
        if request != nil {
            // リクエスト発行
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {
                response, data, connectionErr in
                if connectionErr == nil {
                    var jsonError: NSError?
                    // NSData を JSONObject に変換
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                        options: nil,
                        error: &jsonError)
                    
                    if let jsonArray = json as? NSArray {
                        // JSONObject を TWTRTweet に変換
                        let tmp = TWTRTweet.tweetsWithJSONArray(jsonArray as [AnyObject]) as! [TWTRTweet]
                        // down のときと up のときで更新するIDがことなるんだよなぁ
                        if !tmp.isEmpty {
                            // ID の保持
                            switch direction {
                            case api.INIT:
                                api.since_id = tmp[0].tweetID
                                api.max_id = tmp[tmp.count - 1].tweetID
                                let num = api.max_id.toInt()! - 1
                                api.max_id = num.description
                                break
                            case api.UP:
                                api.since_id = tmp[0].tweetID
                                break
                            case api.DOWN:
                                api.max_id = tmp[tmp.count - 1].tweetID
                                let num = api.max_id.toInt()! - 1
                                api.max_id = num.description
                                break
                            default:
                                break
                            }
                            // 引数に渡す
                            tweets(tmp)
                        } else {
                            // 更新情報が空の場合は，IDを更新しない
                            tweets([])
                        }
                    }
                } else {
                    println("Error: \(connectionErr)")
                }
            })
        } else {
            println("Error: \(clientError)")
        }
    }
    
    
    /**
     * プロフィール情報の表示
     */
    class func getProfile(){
        var myprof: TWTRUser!
        
        Twitter.sharedInstance().APIClient.loadUserWithID(Twitter.sharedInstance().session().userID) {
            (user, error) -> Void in
            // ここでプロフィール情報を取得できる
        }
    }
    
    
    /**
     * ツイートの投稿
     */
    class func composeTweet() {
        let composer = TWTRComposer()
        composer.showWithCompletion { (result) -> Void in
            if (result == TWTRComposerResult.Cancelled) {
                println("Tweet composition cancelled")
            }
            else {
                println("Sending tweet!")
            }
        }
    }
}