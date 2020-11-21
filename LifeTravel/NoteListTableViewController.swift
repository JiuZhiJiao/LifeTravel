//
//  NoteListTableViewController.swift
//  LifeTravel
//
//  Created by JiuZhiJiao on 4/11/20.
//  Copyright © 2020 JiuZhiJiao. All rights reserved.
//

import UIKit

class NoteListTableViewController: UITableViewController, DatabaseListener {
    
    let CELL = "noteCell"
    var notes: [Note] = []
    var selectedNote: Note?
    
    // group notes to sectinos to be suitable for table view
    var sections: [String] = []
    var secNotes: [String: [Note]] = [:]
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.secNotes[sections[section]]!.count
    }
    
    // set the section header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        
        let sectionText = UILabel()
        sectionText.frame = CGRect.init(x: 5, y: 10, width: header.frame.width-10, height: header.frame.height-13)
        sectionText.font = .systemFont(ofSize: 16, weight: .bold)
        sectionText.textColor = .systemGray
        sectionText.text = sections[section]
        
        header.addSubview(sectionText)
        return header
    }
    
    // set the high of each section's header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL, for: indexPath) as! NoteListTableViewCell

        let currentNotes = secNotes[sections[indexPath.section]]
        let note = currentNotes![indexPath.row]
        cell.noteDate.text = note.date
        cell.noteLocation.text = note.location
        cell.noteContent.text = note.content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionName = sections[indexPath.section]
        selectedNote = secNotes[sectionName]?[indexPath.row]
        
        // show detail of the note
        self.performSegue(withIdentifier: "showDetailSegue", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sectionName = sections[indexPath.section]
            let note = secNotes[sectionName]?[indexPath.row]
            
            self.databaseController?.deleteNote(note: note!)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue" {
            let destination = segue.destination as! DetailViewController
            destination.note = selectedNote
        }
    }
    
    // MARK: - Database Listener Functions
    func onNoteListChange(change: DatabaseChange, notes: [Note]) {
        self.notes = notes
        print(notes.count)
        
        // make sectinos of all notes
        setSections()
        
        tableView.reloadData()
    }
    
    // group all notes to sections
    func setSections() {
        sections.removeAll()
        for note in notes {
            let date = String((note.date?.prefix(7)) ?? "2020-02-02")
            if sections.contains(date) == false {
                sections.append(date)
            }
        }
        
        for section in sections {
            var filterNotes: [Note] = []
            
            for note in notes {
                if note.date?.contains(section) == true {
                    filterNotes.append(note)
                }
            }
            secNotes[section] = filterNotes
        }
    }
    

}
