//
//  CategoryPickerViewControllerTableViewController.swift
//  MyLocations
//
//  Created by Christian on 2/13/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

protocol CategoryPickerViewControllerDelegate: class {
    func backTapped(_  categoryViewController: CategoryPickerViewController, selectedCategory: String)
}

class CategoryPickerViewController: UITableViewController {

    var selectedCategoryName = ""
    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"]
    weak var delegate: CategoryPickerViewControllerDelegate?

    init(category: String) {
        self.selectedCategoryName = category
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.backTapped(self, selectedCategory: categories[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.contentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell.textLabel?.textColor = #colorLiteral(red: 0.4812185764, green: 0.4813033938, blue: 0.4812074304, alpha: 1)
        cell.tintColor = #colorLiteral(red: 1, green: 0.7658156157, blue: 0, alpha: 1)
        cell.textLabel?.text = category
        cell.accessoryType = category == selectedCategoryName ? .checkmark : .none

        return cell
    }
}
