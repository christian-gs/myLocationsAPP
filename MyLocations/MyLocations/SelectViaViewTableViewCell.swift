//
//  IconTableViewCell.swift
//  ChecklistApp
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class SelectViaViewTableViewCell: UITableViewCell
{
    var mainLabel = UILabel()
    var selectedImageView = UIImageView()
    var selectedLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.mainLabel.text = "Press to Select"
        self.selectedLabel.text = ""

        for subView in [mainLabel, selectedLabel, selectedImageView] as [UIView] {
            subView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subView)
        }
        self.accessoryType = .disclosureIndicator
        
        NSLayoutConstraint.activate([
            mainLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            mainLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            selectedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            selectedLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
