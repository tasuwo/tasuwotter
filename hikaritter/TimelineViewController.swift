//
//  TimelineViewController.swift
//  hikaritter
//
//  Created by 兎澤佑 on 2015/04/03.
//  Copyright (c) 2015年 兎澤 佑. All rights reserved.
//

import UIKit
import TwitterKit


/**
 * タイムライン表示画面
 */
class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MNMBottomPullToRefreshManagerClient,  TWTRTweetViewDelegate {
    let api = TwitterAPI.sharedInstance
    var tableView: UITableView!
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
            self.view.layoutIfNeeded()
            self.refreshFooter.tableViewReloadFinished()
        }
    }
    var singleTweet: TWTRTweet?
    var prototypeCell: TWTRTweetTableViewCell?
    var addBtn: UIBarButtonItem!
    var refreshControl: UIRefreshControl!
    var refreshFooter: MNMBottomPullToRefreshManager!
    
    var VCtitle: String?
    var VCmode: Int?
    
    
    init(title:String, mode:Int) {
        super.init(nibName: nil, bundle: nil)
        self.VCtitle = title
        self.VCmode = mode
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    /**
     * ロード時
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ページタイトル
        self.title = self.VCtitle
        
        // Navigation bar のしたに tableView をもぐりこませない
        self.edgesForExtendedLayout = UIRectEdge.None
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        // ナビゲーションバーにボタン配置
        addBtn = UIBarButtonItem(image: UIImage(named: "tweet"), style: UIBarButtonItemStyle.Plain, target: self, action: "onClick")
        self.navigationItem.rightBarButtonItem = addBtn
        
        // UITableView の設定
        tableView = UITableView(frame: self.view.bounds)
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "cell")    // Cell名の登録をおこなう.
        tableView.delegate = self                                                               // Delegateを設定
        tableView.dataSource = self                                                             // DataSourceの設定
        self.view.addSubview(tableView)                                                         // Viewに追加
        
        // Refresh Header 表示
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "更新")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // Refresh Fooder 表示
        self.refreshFooter = MNMBottomPullToRefreshManager(pullToRefreshViewHeight: 60.0, tableView: self.tableView, withClient: self)
        
        // タイムラインを読み込む
        loadTweets()
    }
    
    
    /**
     * ツイートをロード
     */
    func loadTweets() {
        // 読み込み
        TwitterAPI.getTimeline(self.VCmode!, direction: self.api.INIT, tweets: {
            twttrs in
            for tweet in twttrs {
                self.tweets.append(tweet)
            }
            }, error: {
                error in
                println(error.localizedDescription)
        })
    }
    
    
    /**
     * ツイートをリフレッシュ
     */
    func refreshTweets() {
        var tmp: [TWTRTweet] = []
        
        // 読み込み
        TwitterAPI.getTimeline(self.VCmode!, direction: self.api.UP, tweets: {
            twttrs in
            if !twttrs.isEmpty {
                for tweet in twttrs {
                    // 新規ツイートの読み込み
                    tmp.append(tweet)
                }
                // 読み込み済みのものと結合
                self.tweets = tmp + self.tweets
            }
            }, error: {
                error in
                println(error.localizedDescription)
        })
    }
    
    
    /**
     * タイムラインを更新
     */
    func refresh() {
        refreshTweets()
        refreshControl.endRefreshing()
    }
    
    
    /**
     * addBtnをタップしたときのアクション
     */
    func onClick() {
        TwitterAPI.composeTweet()
    }
    
    
    // MARK: MNMBottomPullToRefreshManagerClient
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.refreshFooter.tableViewScrolled()
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.refreshFooter.tableViewReleased()
    }
    func bottomPullToRefreshTriggered(manager: MNMBottomPullToRefreshManager!) {
        // 読み込み
        TwitterAPI.getTimeline(self.VCmode!, direction: self.api.DOWN, tweets: {
            twttrs in
            for tweet in twttrs {
                self.tweets.append(tweet)
            }
            }, error: {
                error in
                println(error.localizedDescription)
        })
        self.refreshFooter.tableViewReloadFinished()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.refreshFooter.relocatePullToRefreshView()
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // テーブルビューに表示する行数
        return self.tweets.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // セルのためのテーブルビュー情報を，プレースホルダ識別子によって指定している
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TWTRTweetTableViewCell
        // for TWTRTweetViewDelegate to handling on select
        cell.tweetView.delegate = self
        // ツイート格納
        let tweet = tweets[indexPath.row]
        cell.tag = indexPath.row
        cell.configureWithTweet(tweet)
        
        return cell
    }
    
    
    // MARK: TWTRTweeetViewDelegate
    // tap a cell
    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!) {
        var singletweetVC: UIViewController!
        singletweetVC = SingleTweetViewController(tweet: tweet)
        self.navigationController?.pushViewController(singletweetVC, animated: true)
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweets[indexPath.row]
        return TWTRTweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds))
    }
}