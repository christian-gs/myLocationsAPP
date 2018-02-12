//
//  IconTableViewCell.swift
//  ChecklistApp
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class IconTableViewCell: UITableViewCell
{
    var iconLabel: UILabel = UILabel()
    var iconImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.iconLabel.text = "Icon"
        self.iconImageView.image = UIImage()
        
        self.iconLabel.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconLabel)
        contentView.addSubview(iconImageView)
        self.accessoryType = .disclosureIndicator
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            iconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
