//
//  DoubleLabelTableViewCell.swift
//  ChecklistApp
//
//  Created by Christian on 2/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class DoubleLabelTableViewCell: UITableViewCell
{
    var leftLabel = UILabel()
    var rightLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.leftLabel.text = "Label"
        self.rightLabel.text = "Detail"
        
        for label in [leftLabel, rightLabel] {
            label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
        }
        
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            leftLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            rightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])

        contentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

