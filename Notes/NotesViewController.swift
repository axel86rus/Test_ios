//
//  NotesViewController.swift
//  Notes
//
//  Created by Алексей Лопух on 12.10.2017.
//  Copyright © 2017 Алексей Лопух. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var notesView: UICollectionView!
    @IBOutlet weak var slider: UISlider!
    
    let layoutMinimumLineSpacing: CGFloat = 5
    let layoutMinimumInteritemSpacing: CGFloat = 5
    var fetchResultController: NSFetchedResultsController<NSFetchRequestResult> =
        CoreDataManager.instance.fetchedResultsController("NoteEntity", keyForSort: "title")
    
    var notes: [Note] = []
    var isDelete: Bool = false
    private let dateFormat = "dd-MM-yy HH:mm z"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesView.delegate = self
        notesView.dataSource = self
        
        self.fetchResultController.delegate = self
        
        setupNotebook()
        
        changeSize(slider)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = notesView.dequeueReusableCell(withReuseIdentifier: "Cell" , for: indexPath) as! NoteCell
        
        cell.setNote(note: notes[indexPath.row])
        cell.backgroundColor = UIColor.lightGray
        cell.isDelete = isDelete
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let c = cell as! NoteCell
        c.isDelete = isDelete
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "new" {
            let vc = segue.destination as! NoteEditor
            vc.delegat = self
            vc.note = nil
        }
    }
    
    @IBAction func changeSize(_ sender: Any) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = layoutMinimumLineSpacing
        layout.minimumInteritemSpacing = layoutMinimumInteritemSpacing
        
        let value = CGFloat((sender as! UISlider).value) / 100
        let change = (self.notesView.frame.height < self.notesView.frame.width) ? CGFloat(1.0) : CGFloat(2.5)
        
        let size: CGSize = CGSize(width:self.notesView.frame.width * value ,
                                  height: self.notesView.frame.height * value / change)
        
        layout.itemSize = size
        notesView.setCollectionViewLayout(layout, animated: true)
        
        let cells = notesView.visibleCells as! [NoteCell]
        for cell in cells{
            cell.isDelete = self.isDelete
        }
    }
    
    @IBAction func editCell(_ sender: Any) {
        self.navigationItem.leftBarButtonItem?.title = isDelete ? "Edit" : "Done"
        isDelete = isDelete ? false : true
        notesView.reloadData()
        notesView.performBatchUpdates(nil, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
extension NotesViewController: NotesEditorDelegat, NSFetchedResultsControllerDelegate{
    func addNewNote(newNote: Note) {
        var removeIndex: Int? = nil
        for (index, item) in self.notes.enumerated(){
            if newNote.uid == item.uid{
                removeIndex = index
            }
        }
        if let index = removeIndex{
            self.notes.remove(at: index)
            self.notes.insert(newNote, at: index)
            do{
                try self.fetchResultController.performFetch()
                CoreDataManager.instance.managedObjectContext.delete(self.fetchResultController.object(at: IndexPath(row: index, section: 0)) as! NSManagedObject)
                saveContext()
            } catch {
                print("error")
            }
        }else{
            self.notes.append(newNote)
        }
        
        CoreDataManager.instance.managedObjectContext.performAndWait {
            let entity = NSEntityDescription.entity(forEntityName: "NoteEntity",
                                                    in: CoreDataManager.instance.managedObjectContext)
            let note = NoteEntity(entity: entity!, insertInto: CoreDataManager.instance.managedObjectContext)
            note.content = newNote.content
            note.title = newNote.title
            note.uid = newNote.uid
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = self.dateFormat
            note.date = dateFormatter.string(from: newNote.date)
            self.saveContext()
        }

        self.notesView.reloadData()
        self.notesView.performBatchUpdates(nil, completion: nil)
    }
    
    private func saveContext(){
        CoreDataManager.instance.saveContext()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isDelete{
            let deleteIndex = indexPath.row
            
            self.notes.remove(at: deleteIndex)
            CoreDataManager.instance.managedObjectContext.delete(self.fetchResultController.object(at: indexPath) as!NSManagedObject)
            self.saveContext()
            self.notesView.reloadData()
            self.notesView.performBatchUpdates(nil, completion: nil)
            
        }else{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "change") as! NoteEditor
            if let cell = notesView.cellForItem(at: indexPath) as? NoteCell{
                vc.note = cell.note
                vc.delegat = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func setupNotebook(){
        do {
            try self.fetchResultController.performFetch()
            
            if let result = self.fetchResultController.fetchedObjects as? [NSManagedObject]{
                for item in result {
                    if let note = noteEntityToNote(noteEntity: item){
                        self.notes.append(note)
                    }
                }
            }
        } catch {
            print("Error")
        }
    }
    func noteEntityToNote(noteEntity: NSManagedObject) -> Note?{
        guard let noteEntity = noteEntity as? NoteEntity else{
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dateFormat
        return Note(title: noteEntity.title!,
                    content: noteEntity.content!,
                    date: dateFormatter.date(from: noteEntity.date!)!,
                    uid: noteEntity.uid!)
    }
}
