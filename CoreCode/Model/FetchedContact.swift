//
//  FetchedContact.swift
//  IOSFetchContactsTutorial
//
//  Created by Arthur Knopper on 10/01/2020.
//  Copyright © 2020 Arthur Knopper. All rights reserved.
//

import Foundation
import Contacts
import UIKit

struct FetchedContact {
    var firstName: String
    var lastName: String
    var telephone: String
    var contctImage:Data?
    var selected:Bool
}
