//
//  Functions.swift
//  MyLocations
//
//  Created by Christian on 2/13/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

//coreData Error handling
let CoreDataSaveFailedNotification = Notification.Name(rawValue: "CoreDataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post( name: CoreDataSaveFailedNotification, object: nil)
    // lister for this error in app delegate
}

//return file path of coreData
let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()
