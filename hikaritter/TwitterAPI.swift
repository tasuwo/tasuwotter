import Foundation
import TwitterKit

enum updateMode { case INIT, UP, DOWN }
enum timelineKind { case HOME, MENTION }

class TwitterAPI {
    // Twitter API 用
    private let baseURL = "https://api.twitter.com"
    private let version = "/1.1"
    private var max_id = ""
    private var since_id = ""
    
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
    class func getTimeline(mode: timelineKind, direction: updateMode, tweets: [TWTRTweet]->(), error: (NSError)->()) {
        //////////////////
        // REST API の指定
        let api = self.sharedInstance
        var path = "/statuses/"
        switch mode {
        case .HOME:      path += "home_timeline.json"
        case .MENTION:   path += "mentions_timeline.json"
        default:         println("Error: api error")
        }
        let endpoint = api.baseURL + api.version + path
        // エラー設定
        var clientError: NSError?
        var params: [NSObject : AnyObject]?
        
        ////////////////
        // パラメータ設定
        switch direction {
        case .INIT:  params = nil                        // 初期の読み込み
        case .UP:    params = ["since_id": api.since_id] // 上部更新
        case .DOWN:  params = ["max_id": api.max_id]     // 下部更新
        default:        println("Error: param diff")
        }
        
        //////////////////////
        // NSURLRequest を生成
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET",
            URL: endpoint,
            parameters: params,
            error: &clientError
        )
        
        if request == nil {
            // エラー：クライアントが存在しない．
            println("Error: \(clientError)")
            return
        }
        
        ////////////////
        // リクエスト発行
        Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {
            response, data, connectionErr in
            
            // エラー：リクエストを発行できない
            if connectionErr != nil { println("Error: \(connectionErr)"); return }
            
            var jsonError: NSError?
            // 取得した NSData を JSONObject に変換
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(
                    data,
                    options: nil,
                    error: &jsonError)
            
            if let jsonArray = json as? NSArray {
                // JSONObject を TWTRTweet に変換
                let tweetArray =
                        TWTRTweet.tweetsWithJSONArray(jsonArray as [AnyObject]) as! [TWTRTweet]
                
                // エラー：更新情報が空の場合は，IDを更新しないで終了
                if tweetArray.isEmpty { tweets([]); return }
                    
                // IDの更新：どのIDを更新するかは，更新モードにより異なる．
                if direction == .INIT || direction == .UP {
                    // since_id の更新
                    api.since_id = tweetArray[0].tweetID
                }
                if direction == .INIT || direction == .DOWN {
                    // max_id の更新
                    let tmp = tweetArray[tweetArray.count - 1].tweetID
                    let num = tmp.toInt()! - 1
                    api.max_id = num.description
                }
                
                // 引数に渡す
                tweets(tweetArray)
            }
        })
    }
    
    
    /**
     * プロフィール情報の表示
     */
    class func getProfile(){
        var myprof: TWTRUser!
        Twitter.sharedInstance().APIClient.loadUserWithID(
            Twitter.sharedInstance().session().userID) {
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