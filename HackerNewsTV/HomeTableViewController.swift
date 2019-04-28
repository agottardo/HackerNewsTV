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
        api.getItems(limit: 25, completion: { (items, err) in
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = String(item.point!) + " points | "+(item.url?.host)!
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ReadStoryViewController
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            dest.item = items[indexPath.row]
        }
    }
    

}
