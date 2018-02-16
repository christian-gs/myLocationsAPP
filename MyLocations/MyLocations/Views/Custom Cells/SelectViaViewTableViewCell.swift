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

        self.mainLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.mainLabel.text = "Press to Select"
        self.selectedLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.selectedLabel.text = ""
        self.selectedImageView.isHidden = true
        self.selectedImageView.contentMode = .scaleAspectFit

        for subView in [mainLabel, selectedLabel, selectedImageView] as [UIView] {
            subView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subView)
        }
        self.accessoryType = .disclosureIndicator
        
        NSLayoutConstraint.activate([
            mainLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            mainLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            selectedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedImageView.heightAnchor.constraint(equalToConstant: 260),
            selectedImageView.widthAnchor.constraint(equalToConstant: 260),
            selectedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            selectedLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])

        contentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(image: UIImage) {

        selectedImageView.contentMode = .scaleAspectFit
        selectedImageView.image = image
        selectedImageView.isHidden = false
        mainLabel.isHidden = true
    }
}
