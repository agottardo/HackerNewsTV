//
//  HNAPI.swift
//  HackerNewsTV
//
//  Created by Andrea Gottardo on 2019-04-27.
//  Copyright © 2019 Andrea Gottardo. All rights reserved.
//

import Foundation

// A news story on HN.
struct HNItem {
    var title: String?
    var url: URL?
    var point: Int?
}

// An abstraction to the Hacker News APIs.
class HNAPI {
    /// Fetches `limit` items from the Hacker News API.
    /// - Parameters:
    ///     - limit: Number of news stories to fetch
    ///     - completion: Completion handler
    func getItems(limit: Int, completion: @escaping ([HNItem]?, Error?) -> Void) {
        getTopIds(limit: limit, completion: { ids, err in
            if err != nil {
                completion(nil, err)
            }
            var acc = [HNItem]()
            let group = DispatchGroup()
            for id in ids! {
                self.getItemWithId(group: group, id: id, completion: { item, err in
                    if err != nil {
                        return
                    }
                    acc.append(item!)
                })
            }
            group.notify(queue: .main, execute: {
                print("done with all")
                completion(acc, nil)
            })
        })
    }

    /// Fetches `limit` IDs of top news stories from the Hacker News API.
    /// - Parameters:
    ///     - limit: Number of IDs to fetch
    ///     - completion: Completion handler
    private func getTopIds(limit: Int, completion: @escaping ([Int]?, Error?) -> Void) {
        let endpoint = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")
        let request = URLRequest(url: endpoint!)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil || data == nil || data!.count < 1 || response == nil {
                completion(nil, error!)
            }
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            if var ids = json as? [Int] {
                ids = Array(ids.prefix(upTo: limit))
                completion(ids, nil)
            } else {
                completion(nil, NSError(domain: "hnapi", code: 100, userInfo: nil))
            }
        }.resume()
    }

    /// Fetches the news item with given `id` from the Hacker News API.
    /// Must run as part of a `DispatchGroup` to allow for multiple HTTP requests
    /// to be made at the same time.
    /// - Parameters:
    ///     - group: `DispatchGroup` to enter and leave
    ///     - id: the news item to fetch
    ///     - completion: completion handler
    private func getItemWithId(group: DispatchGroup, id: Int, completion: @escaping (HNItem?, Error?) -> Void) {
        group.enter()
        let endpoint = URL(string: "https://hacker-news.firebaseio.com/v0/item/" + String(id) + ".json")
        let request = URLRequest(url: endpoint!)
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { group.leave() }
            if error != nil || data == nil || data!.count < 1 || response == nil {
                completion(nil, error!)
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let dict = json as? [String: Any?] {
                var item = HNItem()
                if let title = dict["title"] as? String {
                    item.title = title
                } else {
                    completion(nil, NSError(domain: "hnapi", code: 102, userInfo: nil))
                    return
                }
                if let urlString = dict["url"] as? String {
                    item.url = URL(string: urlString)
                    if item.url == nil {
                        // 104: Invalid url format
                        completion(nil, NSError(domain: "hnapi", code: 104, userInfo: nil))
                        return
                    }
                } else {
                    // 103: Invalid url type
                    completion(nil, NSError(domain: "hnapi", code: 103, userInfo: nil))
                    return
                }
                if let score = dict["score"] as? Int {
                    item.point = score
                } else {
                    // 105: Invalid score type
                    completion(nil, NSError(domain: "hnapi", code: 105, userInfo: nil))
                    return
                }
                completion(item, nil)
                return
            } else {
                completion(nil, NSError(domain: "hnapi", code: 101, userInfo: nil))
                return
            }
        }.resume()
    }

    /// Fetches a text-only version of the webpage contents located at `url`.
    /// - Parameters:
    ///     - url: webpage to convert to text
    ///     - completion: Completion handler
    /// - Todo: Find an API that works better (and which possibly scales well)
    func extractURL(url: String, completion: @escaping (String?, Error?) -> Void) {
        let endpoint = URL(string: "https://boilerpipe-web.appspot.com/extract?url=" + url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&extractor=ArticleExtractor&output=text&extractImages=&token=")
        let request = URLRequest(url: endpoint!)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil || data == nil || data!.count < 1 || response == nil {
                completion(nil, error!)
            }
            let text = String(data: data!, encoding: .utf8)
            if text != nil {
                completion(text, nil)
            } else {
                completion(nil, NSError(domain: "hnapi", code: 106, userInfo: nil))
            }
        }.resume()
    }
}
