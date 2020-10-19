//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Anna Solovyeva on 25/07/2020.
//  Copyright © 2020 Anna Solovyeva. All rights reserved.
//

import UIKit
import Foundation

class MemeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var memeTableView: UITableView!
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memeTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")!
        let meme = memes[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = "\(meme.topText!)...\(meme.bottomText!)"
        cell.imageView?.image = meme.memedImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(identifier: "MemeDetailViewController") as! MemeDetailViewController
        controller.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func CreateMeme (_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier:"MemeCreation")
        present(controller!, animated: true, completion: nil)
    }
    
}
