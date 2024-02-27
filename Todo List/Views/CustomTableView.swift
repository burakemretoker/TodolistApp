//
//  CustomTableView.swift
//  Todo List
//
//  Created by Burak Emre Toker on 24.02.2024.
//

import Foundation


import UIKit

class CustomTableView: UITableView {

    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
    
    
}
