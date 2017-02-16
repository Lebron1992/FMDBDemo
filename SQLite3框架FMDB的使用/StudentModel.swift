//
//  StudentModel.swift
//  SQLite3框架FMDB的使用
//
//  Created by 曾文志 on 14/02/2017.
//  Copyright © 2017 Lebron. All rights reserved.
//

import UIKit

class StudentModel: NSObject {

    var name: String
    var age: Int
    var score: Double
    var classModel: ClassModel
    
    init(name: String, age: Int, score: Double, classModel: ClassModel) {
        self.name = name
        self.age = age
        self.score = score
        self.classModel = classModel
    }
    
}
