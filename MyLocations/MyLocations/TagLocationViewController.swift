//
//  SecondViewController.swift
//  MyLocations
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

class TagLocationViewController: UITableViewController, CategoryPickerViewControllerDelegate {

    private var location : CLLocation
    private var address: String

    private var selectedCategory = "No Category"

    init(location: CLLocation, address: String) {
        self.location = location
        self.address = address
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Tag Location"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: "textViewCell")
        tableView.register(SelectViaViewTableViewCell.self, forCellReuseIdentifier: "selectViaViewCell")
        tableView.register(DoubleLabelTableViewCell.self, forCellReuseIdentifier: "doubleLabelCell")

        //gesture recogniser to hide keyboard when user clicks off textView cell
        let gestureRecognizer = UITapGestureRecognizer(target: self,  action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func doneTapped() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Tagged"

        let delayInSeconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds,
            execute: {
                hudView.hide()
                self.dismiss(animated: true, completion: nil)
        })
    }

    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    //function to hide keyboard when user clicks off textView cell
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        guard indexPath == nil || indexPath!.section != 0 || indexPath!.row != 0 else { return }

        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0) ) as! TextViewTableViewCell
        cell.textView.resignFirstResponder()
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.cellForRow(at: indexPath) as! TextViewTableViewCell
                cell.textView.becomeFirstResponder()
            }
            else if indexPath.row == 1 {
                let categoryPickerViewController = CategoryPickerViewController(category: self.selectedCategory)
                categoryPickerViewController.delegate = self
                navigationController?.pushViewController(categoryPickerViewController, animated: true)
            }
        }
        else if indexPath.section == 1 {
            let categoryPickerViewController = CategoryPickerViewController(category: self.selectedCategory)
            categoryPickerViewController.delegate = self
            navigationController?.pushViewController(categoryPickerViewController, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "DESCRIPTION"
        }
        if section == 1 {
            return "PHOTO"
        }
        if section == 2 {
            return "LOCATION DETAILS"
        }
        return ""
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        var cell: UITableViewCell?

        switch section {
        case 0:
            if row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath)
            }
            else if row == 1 {
                cell = configureSelectViaViewCell(indexPath: indexPath)
            }
        case 1:
            cell = configureSelectViaViewCell(indexPath: indexPath)
        case 2:
            cell = configureDoubleLabelCell(indexPath: indexPath)
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }

        return cell!

    }

    func configureSelectViaViewCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectViaViewCell", for: indexPath) as! SelectViaViewTableViewCell
        switch indexPath.section {
        case 0:
            cell.mainLabel.text = "Category"
            cell.selectedLabel.text = selectedCategory
        case 1:
            cell.mainLabel.text = "Add Photo"
        default:
            break
        }
        return cell
    }

    func configureDoubleLabelCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "doubleLabelCell", for: indexPath) as! DoubleLabelTableViewCell
        switch indexPath.row {
        case 0:
            cell.leftLabel.text = "Latitude"
            cell.rightLabel.text = String(format: "%.8f", self.location.coordinate.latitude)
        case 1:
            cell.leftLabel.text = "Longitude"
            cell.rightLabel.text = String(format: "%.8f",self.location.coordinate.longitude)
        case 2:
            cell.leftLabel.text = "Address"
            cell.rightLabel.numberOfLines = 0
            cell.rightLabel.text = self.address
        case 3:
            cell.leftLabel.text = "Date"
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            cell.rightLabel.text = formatter.string(from: Date())
        default:
            break
        }
        cell.selectionStyle = .none
        return cell
    }

    //MARK:- CategoryPickerViewControllerDelegate Methods
    func backTapped(_ categoryViewController: CategoryPickerViewController, selectedCategory: String) {
        self.selectedCategory = selectedCategory
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }

}
