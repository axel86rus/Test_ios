//
//  Note.swift
//  Notes
//
//  Created by Алексей Лопух on 12.10.2017.
//  Copyright © 2017 Алексей Лопух. All rights reserved.
//

import Foundation

struct Note {
    let title: String
    let content: String
    let date: Date
    let uid: String
    
    init(title: String, content: String, date: Date, uid: String = UUID().uuidString) {
        self.title = title
        self.date = date
        self.content = content
        self.uid = uid
    }
}
