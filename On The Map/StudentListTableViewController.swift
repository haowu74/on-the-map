//
//  StudentListTableViewController.swift
//  On The Map
//
//  Created by Hao Wu on 21/3/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit

class StudentListTableViewCell : UITableViewCell {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var studentInfoLabel: UILabel!
    @IBOutlet weak var studentUrl: UITextView!
    
    // MARK: Function of UITableViewCell
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
}

class StudentListTableViewController: UITableViewController {

    // MARK: Properties
    // The dictionary to contain all the 1000 student locations
    var locations: [StudentLocation] = []

    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: - Functions of UITableViewController

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentListCellId") as! StudentListTableViewCell

        cell.studentInfoLabel!.text = "\(locations[(indexPath as NSIndexPath).row].FirstName) \(locations[(indexPath as NSIndexPath).row].LastName)"
        let studentUrl = "\(locations[(indexPath as NSIndexPath).row].MediaUrl)"
        let attributedString = NSMutableAttributedString(string: studentUrl)
        attributedString.addAttribute(.link, value: studentUrl, range: NSRange(location: 0, length: studentUrl.count))
        cell.studentUrl!.attributedText = attributedString
        return cell
    }
}
