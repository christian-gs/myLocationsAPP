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
        locationImageView.contentMode = .scaleAspectFill

        for view in [mainLabel, subLabel, locationImageView] as [UIView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }

        NSLayoutConstraint.activate([
            locationImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            locationImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            locationImageView.heightAnchor.constraint(equalToConstant: 66),
            locationImageView.widthAnchor.constraint(equalToConstant: 66),
            mainLabel.leadingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: 20),
            mainLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            subLabel.leadingAnchor.constraint(equalTo: mainLabel.leadingAnchor),
            subLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 10)
        ])


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
