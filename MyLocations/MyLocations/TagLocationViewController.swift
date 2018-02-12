//
//  SecondViewController.swift
//  MyLocations
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class TagLocationViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)

        title = "Tag Location"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: "textViewCell")
        tableView.register(IconTableViewCell.self, forCellReuseIdentifier: "iconCell")
        tableView.register(DoubleLabelTableViewCell.self, forCellReuseIdentifier: "doubleLabelCell")
    }

    @objc func doneTapped() {

    }

    @objc func cancelTapped() {

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        if section == 1 {
           return 1
        }
        if section == 2 {
            return 4
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if section == 0 {
            if row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath)
                return cell
            }
            if row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "iconCell", for: indexPath)
                return cell
            }
        }
        else if section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "iconCell", for: indexPath)
            return cell
        }
        else if section == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "doubleLabelCell", for: indexPath)
            return cell
        }

        return cell
    }

}

