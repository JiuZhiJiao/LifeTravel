//
//  DatabaseProtocol.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

protocol DatabaseListener: AnyObject {
    func onNoteListChange(change:DatabaseChange, notes:[Note])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addNote(date:String, location:String, lat:Double, long: Double, photo:String, content: String) -> Note
    func addNote(date:String, location:String, lat:Double, long: Double, content: String) -> Note
    func deleteNote(note:Note)
    func addListener(listener:DatabaseListener)
    func removeListener(listener:DatabaseListener)
}
