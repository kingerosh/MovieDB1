//
//  ThemeCollectionViewCell.swift
//  MovieDB
//
//  Created by Ерош Айтжанов on 02.08.2024.
//

import UIKit
import SnapKit

class ThemeCollectionViewCell: UICollectionViewCell {
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .systemGray5
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? .white : .black
            label.backgroundColor = isSelected ? .red : .systemGray5
        }
    }
}

