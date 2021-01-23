//
//  String+BSW.swift
//  BlackStarWear
//
//  Created by Georgy Gorbenko on 18.12.2020.
//

import UIKit

extension String {
    
    var url: URL? {
        
        return URL(string: self)
    }

    func joined(_ other: String?, separator: String = " ") -> String {
        
        let other = other ?? ""
        switch (isEmpty, other.isEmpty) {
        case (false, false):
            return self + separator + other
        case (true, true):
            return ""
        case (true, false):
            return other
        case (false, true):
            return self
        }
    }
    
    func localized(comment: String = "") -> String {
        
        return NSLocalizedString(self, comment: comment)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return ceil(boundingBox.width)
    }
    
    static func joined(_ start: String?, _ other: String?, separator: String = " ") -> String? {
        
        return start?.joined(other, separator: separator) ?? other
    }
    
    func size(font: UIFont, width: CGFloat, options: NSStringDrawingOptions = [.usesLineFragmentOrigin]) -> CGSize {
    
        return NSAttributedString(string: self, attributes: [.font: font])
            .size(withConstrainedWidth: width, options: options)
    }
    
    func size(font: UIFont, width: CGFloat, numberOfLines: Int) -> CGSize {
        
        let rectSize = size(font: font, width: width)
        let height = min(rectSize.height, font.lineHeight * CGFloat(numberOfLines))
        return CGSize(width: rectSize.width, height: height)
    }
    
}

extension NSAttributedString {
    
    func size(withConstrainedWidth width: CGFloat,
              options: NSStringDrawingOptions = [.usesLineFragmentOrigin]) -> CGSize {
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: options, context: nil)
        
        return CGSize(width: boundingBox.width.rounded(.up),
                      height: boundingBox.height.rounded(.up) + 1)
    }
    
}
