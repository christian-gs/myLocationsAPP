//
//  SubTitleTableViewCell.swift
//  MyLocations
//
//  Created by Christian on 2/14/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class LocationsTableViewCell: UITableViewCell {

    let mainLabel = UILabel()
    let subLabel = UILabel()
    let locationImageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        mainLabel.font = UIFont.boldSystemFont(ofSize: 17)
        mainLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        subLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        locationImageView.contentMode = .scaleAspectFill

        for view in [mainLabel, subLabel, locationImageView] as [UIView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            locationImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            locationImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            locationImageView.heightAnchor.constraint(equalToConstant: 66),
            locationImageView.widthAnchor.constraint(equalToConstant: 66),
            mainLabel.leadingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: 20),
            mainLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            subLabel.leadingAnchor.constraint(equalTo: mainLabel.leadingAnchor),
            subLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 10)
        ])

        locationImageView.layer.masksToBounds = true
        locationImageView.layer.cornerRadius = 33
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0,right: 0)

        contentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
