//
//  ViewController.swift
//  SQLite3框架FMDB的使用
//
//  Created by 曾文志 on 14/02/2017.
//  Copyright © 2017 Lebron. All rights reserved.
//

import UIKit
import FMDB

class ViewController: UIViewController {

    private var db: FMDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取路径
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let schoolPath = fileURL!.path + "/school.db"
        print(schoolPath)
        
        // 创建表格
        if let db = FMDatabase(path: schoolPath) {
            self.db = db
        }
        else {
            print("无法创建数据库")
            return
        }
        
        // 打开表格
        guard db.open() else {
            print("无法打开数据库")
            return
        }
    }
    
    // MARK: - Actions
    
    @IBAction func create() {
        createTable()
    }
    
    @IBAction func drop() {
        dropTable()
    }

    @IBAction func insert() {
        insert(students: getStudents(), andClasses: getClasses())
    }
    
    @IBAction func update() {
        updateData()
    }
    
    @IBAction func query() {
        queryData()
    }
    
    @IBAction func computeCount() {
        computeCountOfAllRecords()
    }
    
    @IBAction func order() {
        orderByAge()
    }
    
    @IBAction func limit() {
        selectDataWithLimitation()
    }
    
    @IBAction func closeDatabase() {
        if db.close() {
            print("数据库已关闭")
        }
    }
    
    
    // MARK: - Private implementation

    // 创表（主键、字段约束、外键）
    private func createTable() {
        // 创表学生表：主键名称为integer类型的id、自动增长；文本类型的name、不为空；integer类型的age、不为空；real类型的score、不为空；
        // integer类型的class_id、不为空；fk_student_class外键，student表格的class_id字段引用class表格的id字段。
        let createStudentTable = "create table student (id integer primary key autoincrement, name text not null, age integer not null, score real not null, class_id integer not null, constraint fk_student_class foreign key (class_id) references class (id));"
        
        // 创建班级表：主键名称为integer类型的id、自动增长；文本类型的name、不为空
        let createClassTable = "create table class (id integer primary key autoincrement, name text not null);"
        
        do {
            try db.executeUpdate(createStudentTable, values: nil)
            try db.executeUpdate(createClassTable, values: nil)
            print("表格创建成功")
        }
        catch {
            print("创建表格错误: \(error.localizedDescription)")
        }
    }
    
    // 删表
    private func dropTable() {
        do {
            try db.executeUpdate("drop table student", values: nil)
            try db.executeUpdate("drop table class", values: nil)
            print("表格删除成功")
        }
        catch {
            print("删表错误: \(error.localizedDescription)")
        }
    }
    
    
    // 插入数据
    private func insert(students: [StudentModel], andClasses classes: [ClassModel]) {
        
        for aClass in classes {
            do {
                try db .executeUpdate("insert into class (name) values (?);", values: [aClass.name])
                print("\(aClass.name)插入成功")
            }
            catch {
                print("数据插入错误: \(error.localizedDescription)")
            }
        }
        
        for student in students {
            do {
                try db.executeUpdate("insert into student (name, age, score, class_id) values (?, ?, ?, ?);", values: [student.name, student.age, student.score, getClassID(withName: ViewController.ClassName(rawValue: student.classModel.name)!)])
                print("\(student.name)插入成功")
            }
            catch {
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    
    
    // 更新数据
    private func updateData() {
        do {
            // 把表格中所有年龄大于等于30的记录，年龄改为29
            try db.executeUpdate("update student set age = 29 where age >= 30;", values: nil)
            print("数据更新成功")
        }
        catch {
            print("数据更新错误：\(error.localizedDescription)")
        }
    }
    
    
    // 查询
    private func queryData() {
        do {
            // 从student表格中查询年龄大于等于18的记录
            let rs = try db.executeQuery("select * from student where age >= 18;", values: nil)
            
            while rs.next() {
                let name = rs.string(forColumn: "name")
                let age = rs.int(forColumn: "age")
                let score = rs.double(forColumn: "score")
                print("姓名: \(name)，年龄：\(age), 分数：\(score)")
            }
        }
        catch {
            print("数据更新错误：\(error.localizedDescription)")
        }
    }
    
    // 计算记录的数量
    private func computeCountOfAllRecords() {
        do {
            let rs = try db.executeQuery("select count(age) from student where age >= 18;", values: nil)
            while rs.next() {
                let count = rs.int(forColumnIndex: 0)
                print("记录总数为：\(count)")
            }
        }
        catch {
            print("计算总数量错误：\(error.localizedDescription)")
        }
    }
    
    
    // 排序
    private func orderByAge() {
        do {
            // asc：升序。 desc：降序
            let rs = try db.executeQuery("select * from student order by age asc;", values: nil)
            
            while rs.next() {
                let name = rs.string(forColumn: "name")
                let age = rs.int(forColumn: "age")
                let score = rs.double(forColumn: "score")
                print("姓名: \(name)，年龄：\(age), 分数：\(score)")
            }
        }
        catch {
            print("排序错误：\(error.localizedDescription)")
        }
    }
    
    // limit
    private func selectDataWithLimitation() {
        do {
            let rs = try db.executeQuery("select * from student order by score desc limit 5;", values: nil)
            
            while rs.next() {
                let name = rs.string(forColumn: "name")
                let age = rs.int(forColumn: "age")
                let score = rs.double(forColumn: "score")
                print("姓名: \(name)，年龄：\(age), 分数：\(score)")
            }
        }
        catch {
            print("限制数量错误：\(error.localizedDescription)")
        }
    }
    
    
    private func getClasses() -> [ClassModel] {
        let ios = ClassModel(name: ClassName.ios.rawValue)
        let android = ClassModel(name: ClassName.android.rawValue)
        let html5 = ClassModel(name: ClassName.html5.rawValue)
        let java = ClassModel(name: ClassName.java.rawValue)
        
        return [ios, android, html5, java]
    }
    
    private func getStudents() -> [StudentModel] {
        // 班级
        var ios, android, html5, java:ClassModel!
        
        for aClass in getClasses() {
            switch aClass.name {
            case ClassName.ios.rawValue:
                ios = aClass
                
            case ClassName.android.rawValue:
                android = aClass
                
            case ClassName.html5.rawValue:
                html5 = aClass
                
            case ClassName.java.rawValue:
                java = aClass
                
            default:
                break
            }
        }
        
        // android班
        let zhangsan = StudentModel(name: "张三", age: 18, score: 59, classModel: android)
        let lisi = StudentModel(name: "李四", age: 19, score: 65, classModel: android)
        let wangwu = StudentModel(name: "王五", age: 17, score: 80, classModel: android)
        let zhaoliu = StudentModel(name: "赵六", age: 16, score: 95, classModel: android)
        
        // HTML5班
        let xiaoming = StudentModel(name: "小明", age: 20, score: 75, classModel: html5)
        let xiaofang = StudentModel(name: "小芳", age: 21, score: 79, classModel: html5)
        
        // Java班
        let xiaohong = StudentModel(name: "小红", age: 25, score: 85, classModel: java)
        let xiaolong = StudentModel(name: "小龙", age: 26, score: 80, classModel: java)
        
        // iOS班
        let james = StudentModel(name: "詹姆斯", age: 32, score: 95, classModel: ios)
        let irving = StudentModel(name: "欧文", age: 24, score: 89, classModel: ios)
        
        return [zhangsan, lisi, wangwu, zhaoliu, xiaoming, xiaofang, xiaohong, xiaolong, james, irving]
    }
    
    private func getClassID(withName name: ClassName) -> Int {
        switch name {
        case .ios:
            return ClassID.ios.rawValue
            
        case .android:
            return ClassID.android.rawValue
            
        case .html5:
            return ClassID.html5.rawValue
            
        case .java:
            return ClassID.java.rawValue
        }
    }
    
    private enum ClassName: String {
        case ios, android, html5, java
    }
    
    private enum ClassID: Int {
        case ios, android, html5, java
    }

}

