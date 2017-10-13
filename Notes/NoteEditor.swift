//
//  NoteEditor.swift
//  Notes
//
//  Created by Алексей Лопух on 12.10.2017.
//  Copyright © 2017 Алексей Лопух. All rights reserved.
//

import UIKit

internal protocol NotesEditorDelegat: NSObjectProtocol{
    func addNewNote(newNote: Note)
}

class NoteEditor: UIViewController, UITextViewDelegate {
    weak internal var delegat: NotesEditorDelegat?
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var titleView: UITextField!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var scroll: UIScrollView!
    var note: Note?
    
    private let dateFormat = "dd-MM-yy HH:mm z"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.delegate = self

        if (note == nil){
            note = Note(title: "", content: "", date: Date())
        }
        parseNote()
        
        textViewDidChange(content)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        scroll.addGestureRecognizer(gestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func parseNote() {
        self.titleView.text = self.note!.title
        self.content.text = self.note!.content
        
        setDate(newDate: self.note!.date)
    }
    func setDate(newDate: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = self.dateFormat
        
        let stringDate = dateFormatter.string(from: newDate)
        
        self.date.text = stringDate
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    @objc func keyboardWillShow(notification:NSNotification) {
        adjustingHeigth(show: true, notification: notification)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        adjustingHeigth(show: false, notification: notification)
    }
    
    func adjustingHeigth(show: Bool, notification: NSNotification){
        var userInfo = notification.userInfo!
        let keyboardFrame: CGRect = (
            userInfo[(show ? UIKeyboardFrameEndUserInfoKey : UIKeyboardFrameBeginUserInfoKey)]
                as! NSValue)
            .cgRectValue
        
        let chagneInHeigth = keyboardFrame.height  * (show ? 1 : -1)

        scroll.contentInset.bottom += chagneInHeigth
        
        scroll.scrollIndicatorInsets.bottom += chagneInHeigth
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textViewSize = content.sizeThatFits(CGSize(width: textView.frame.size.width, height: .greatestFiniteMagnitude))
        textViewHeight.constant = textViewSize.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func creatNote() -> Note{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dateFormat
        
        return Note(title: titleView.text! ,
                    content: content.text,
                    date: dateFormatter.date(from: date.text!)!,
                    uid: note!.uid)
    }
    
    @IBAction func save(_ sender: Any) {
        let newNote = creatNote()
        self.delegat?.addNewNote(newNote: newNote)
        self.navigationController?.popViewController(animated: true)
    }
    
}
