//
//  popUpViewController.swift
//  FormFour
//
//  Created by Mallikharjuna avula on 28/11/19.
//  Copyright © 2019 Mallikharjuna avula. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class popUpViewController: UIViewController {

    let dBag = DisposeBag()
    @IBOutlet weak var outPutText: UILabel!
    @IBOutlet weak var columnsText: UITextField!
    @IBOutlet weak var rowsText: UITextField!
    @IBOutlet weak var popUpVIew: UIView!
    @IBOutlet weak var DisplayLabel: UILabel!
    weak var delegate: loadGame?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(resign))
        view.addGestureRecognizer(tap)
        
        Observable.combineLatest(rowsText.rx.controlEvent(.editingDidEnd).asObservable(),columnsText.rx.controlEvent(.editingDidEnd).asObservable())
        .subscribe(onNext: { [weak self] _ in
            if let rows = Int((self?.rowsText.text!)!), let columns = Int((self?.columnsText.text!)!){
                if rows > 12 || rows < 7 || columns < 6 || columns > 9{
                    self?.outPutText.text = "rows should be max 12 and min 7 \ncolumns should be min 6 and max 9"
                }
                else{
                    self?.delegate?.dismissVC(rows: rows, columns: columns)
                }
            }
            else{
                self?.outPutText.text = "Fill every textField"
            }
        })
        .disposed(by: dBag)
    }
    
    @objc func resign(){
        rowsText.resignFirstResponder()
        columnsText.resignFirstResponder()
    }
    
    func setUpView(){
        
        rowsText.keyboardType = .decimalPad
        columnsText.keyboardType = .decimalPad
        rowsText.placeholder = "rows"
        columnsText.placeholder = "columns"
        DisplayLabel.text = "Enter the desired rows and columns"
        outPutText.text = ""
    }
}
