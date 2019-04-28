//
//  HomeTableViewController.swift
//  HackerNewsTV
//
//  Created by Andrea Gottardo on 2019-04-27.
//  Copyright © 2019 Andrea Gottardo. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    let api = HNAPI()
    var items = [HNItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("About to fetch items.")
        api.getItems(limit: 25, completion: { items, err in
            if err != nil {
                NSLog("error: " + err!.localizedDescription)
                return
            }
            NSLog("Fetched " + String(items!.count) + " items.")
            self.items = items!
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = String(item.point!) + " points | " + (item.url?.host)!
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ReadStoryViewController
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            dest.item = items[indexPath.row]
        }
    }
}
