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

        cell.textLabel?.text = category
        cell.accessoryType = category == selectedCategoryName ? .checkmark : .none

        return cell
    }
}
