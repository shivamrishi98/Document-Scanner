//
//  Extensions.swift
//  DocumentScanner
//
//  Created by Shivam Rishi on 16/03/21.
//

import Foundation


extension DateFormatter {
    
    static let dateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY hh:mm a"
        return dateFormatter
    }()
    
    static let displayDateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
}

extension String {
    static func formattedDate(string: String) -> String {
        guard let date = DateFormatter.dateFormatter.date(from: string) else {
            return string
        }
        return DateFormatter.displayDateFormatter.string(from: date)
    }
}

extension Notification.Name {
    static let documentAddedNotification = Notification.Name("documentAddedNotification")
}

