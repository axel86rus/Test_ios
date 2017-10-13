//
//  NoteCell.swift
//  Notes
//
//  Created by Алексей Лопух on 12.10.2017.
//  Copyright © 2017 Алексей Лопух. All rights reserved.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var content: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var isDelete: Bool = false{
        didSet{
            if isDelete{
                v.frame = self.bounds
                v.backgroundColor = UIColor.clear
                addSubview(v)
                v.setNeedsDisplay()
            }else{
                v.removeFromSuperview()
            }
        }
    }
    var v = DeleteView()
    var note: Note!
    
    func setNote(note: Note){
        self.note = note
        content.text = note.content
        titleView.text = note.title
    }
    
}

class DeleteView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {return}
        context.setFillColor(UIColor.red.withAlphaComponent(0.5).cgColor)
        context.fill(rect)
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokeEllipse(in: CGRect(x: self.center.x - 15,
                                         y: self.center.y - 15,
                                         width: 30,
                                         height: 30))
        
        context.move(to: CGPoint(x: center.x - 15, y: center.y - 15))
        context.addLine(to: CGPoint(x: center.x + 15, y: center.y + 15))
        context.move(to: CGPoint(x: center.x + 15, y: center.y - 15))
        context.addLine(to: CGPoint(x: center.x - 15, y: center.y + 15))
        context.strokePath()
    }
}
