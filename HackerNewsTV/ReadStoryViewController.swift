//
//  ReadStoryViewController.swift
//  HackerNewsTV
//
//  Created by Andrea Gottardo on 2019-04-27.
//  Copyright © 2019 Andrea Gottardo. All rights reserved.
//

import UIKit

class ReadStoryViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var item : HNItem?
    let api = HNAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.indirect.rawValue] as [NSNumber]
        api.extractURL(url: (item?.url!.absoluteString)!) { (str, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.textView.text = str
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
