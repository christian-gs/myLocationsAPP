//
//  Functions.swift
//  MyLocations
//
//  Created by Christian on 2/13/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

//return file path of coreData
let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()
