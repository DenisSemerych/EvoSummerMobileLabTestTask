//
//  Data.swift
//  EvoSummerMobileLabTestTask
//
//  Created by Denis Semerych on 5/19/19.
//  Copyright © 2019 Denis Semerych. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object {
    
    @objc dynamic var date = Date()
    @objc dynamic var text = ""
}
