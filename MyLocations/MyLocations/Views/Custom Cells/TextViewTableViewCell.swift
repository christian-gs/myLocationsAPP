//
//  TextFieldTableViewCell.swift
//  ChecklistApp
//
//  Created by Christian on 2/8/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class TextViewTableViewCell : UITableViewCell
{
    var textView = UITextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // initialise cutom cells
        textView.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(self.textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            textView.heightAnchor.constraint(equalToConstant: 60)
        ])

        contentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
