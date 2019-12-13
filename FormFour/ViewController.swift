//
//  ViewController.swift
//  FormFour
//
//  Created by Mallikharjuna avula on 28/11/19.
//  Copyright © 2019 Mallikharjuna avula. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxSwift

class ViewController: UIViewController, CBCentralManagerDelegate,CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var dLabel: UILabel!
    let id  = CBUUID(string: "13D7F1B5-6B3B-4EEA-9A9A-88E347B31C3B")
    var oPeripheral: CBPeripheral?
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state{
            
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        case .poweredOn:
            let characteristic = CBMutableCharacteristic(type: id, properties: [.read,.notify,.writeWithoutResponse], value: nil, permissions: [.readable,.writeable])
            let service = CBMutableService(type: id, primary: true)
            service.characteristics = [characteristic]
            peripheral.add(service)
            peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service.uuid]])
        @unknown default:
            break
        }
        
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        case .poweredOn:
            let id  = CBUUID(string: "13D7F1B5-6B3B-4EEA-9A9A-88E347B31C3B")
            central.scanForPeripherals(withServices: [id])
        @unknown default:
            break
        }
    }

    @IBOutlet weak var bluetooth: UIButton!
    @IBOutlet weak var gameView: gameView!
    var startGame: restartGame?
    var first = true
    let disposeBag = DisposeBag()
    var cbManager: CBCentralManager?
    var pManager: CBPeripheralManager?
    var char: CBCharacteristic?
    var columnTouched = 0
    
    override func viewDidLayoutSubviews() {
        let tap = UITapGestureRecognizer(target: gameView.self, action: #selector(gameView.touchPoint(_:)))
        gameView.addGestureRecognizer(tap)
        let a = self.tabBarItem.title
        if a!.contains("comp"){
            gameView.comp = true
            bluetooth.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startGame?.restart()
        first = false
        bluetooth.isHidden = false
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        bluetooth.rx.tap.subscribe(onNext:{
            self.connectBluetooth()
        })
        .disposed(by: disposeBag)
        columnTouched = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameView.send = self
        
    }
    
    func connectBluetooth(){
        cbManager = CBCentralManager(delegate: self, queue: nil)
        pManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    //handling peripheral
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil{
            print(error!)
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil{
            print(error!)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        request.value = "\(gameView.rows)\(gameView.columns)".data(using: .utf8)
        peripheral.respond(to: request, withResult: .success)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        if let data = String(data: requests[0].value ?? Data(), encoding: .utf8){
            gameView.columnTouched = Int(data)!
            gameView.dropItem()
            gameView.opponent = false
        }
        peripheral.respond(to: requests[0], withResult: .success)
    }
    //handling central
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        peripheral.discoverServices([id])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.oPeripheral = peripheral
        self.oPeripheral?.delegate = self
        central.connect(oPeripheral!)
        central.stopScan()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{
            peripheral.discoverCharacteristics([id], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics!{
            char = characteristic
            if characteristic.properties.contains(.notify){
                oPeripheral!.setNotifyValue(true, for: char!)
            }
            peripheral.readValue(for: characteristic)
            switch characteristic.properties{
            case .read:
                break
            default:
                break
            }
            //peripheral.writeValue(Data(), for: characteristic, type: .withoutResponse)
        }
    }
    
    //if characteristic data cannot be readable then error will be given check its property whether readable r not in above method
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case id:
            if let data = characteristic.value{
                let stringData = String(data: data, encoding: .utf8)!
                if let numberData = Int(stringData){
                    let peripheralColumns = numberData%10
                    let peripheralRows = (numberData/10)%10
                    if gameView.columns == peripheralColumns && gameView.rows == peripheralRows{
                        dLabel.text = "Play"
                        gameView.bluetooth = true
                        bluetooth.isHidden = true
                    }
                    else{
                        dLabel.text = "the rows or ccolumns are different"
                        cbManager?.cancelPeripheralConnection(oPeripheral!)
                        pManager?.removeAllServices()
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil{
            print(error!)
        }
    }
}

extension ViewController: send{
    func sendMove(column: Int) {
        columnTouched = column
        oPeripheral!.writeValue("\(columnTouched)".data(using: .utf8)!, for: char!, type: .withoutResponse)
    }
}
