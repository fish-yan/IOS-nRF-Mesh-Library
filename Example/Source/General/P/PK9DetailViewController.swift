//
//  PK9DetailViewController.swift
//  nRF Mesh
//
//  Created by yan on 19/1/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

enum K9OptionsType: UInt8 {
    case onOff = 0x0
    case emergency = 0x4
    
    var text: String {
        switch self {
        case .onOff:
            return "ON/OFF"
        case .emergency:
            return "Emergency"
        }
    }
}

enum K9ControlType: UInt8 {
    case click = 0x0
    case longPress = 0x1
    case alwaysOn = 0x2
    
    var text: String {
        switch self {
        case .click:
            return "Click"
        case .longPress:
            return "Long Press"
        case .alwaysOn:
            return "Always On"
        }
    }
}

enum K9RegionType: UInt8 {
    case light = 0x0
    case zone = 0x1
    
    var text: String {
        switch self {
        case .light:
            return "Light"
        case .zone:
            return "Zone"
        }
    }
}

enum K9TaskType {
    case connect
    case control
    case option
}

class PK9DetailViewController: UIViewController {
        
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var optionsTF: UITextField!
    @IBOutlet weak var controlTF: UITextField!
    @IBOutlet weak var targetView: UIStackView!
    @IBOutlet weak var targetArrowImageView: UIImageView!
    
    @IBOutlet weak var regionTF: UITextField!
    var callback: ((GLK9) -> Void)?
    
    var k9: GLK9?
    
    var node: Node!
    
    private var messageManager = MeshMessageManager()
    
    private var tasks: [K9TaskType: Any?] = [:]
    
    private var option: K9OptionsType = .onOff {
        didSet {
            optionsTF.text = option.text
        }
    }
    private var control: K9ControlType = .click {
        didSet {
            controlTF.text = control.text
        }
    }
    
    private var region: K9RegionType = .light {
        didSet {
            regionTF.text = region.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.setBackgroundColor(color: .accent, forState: .normal)
        saveBtn.setBackgroundColor(color: UIColor(white: 0.7, alpha: 1), forState: .disabled)
        if let k9 {
            title = k9.name
            nameTF.text = k9.name
            numberTF.text = "\(k9.number)"
            option = K9OptionsType(rawValue: k9.option) ?? .onOff
            control = K9ControlType(rawValue: k9.control) ?? .click
            region = K9RegionType(rawValue: k9.target) ?? .light
        } else {
            saveBtn.isEnabled = false
            title = Localized("Create a new K9")
            let k9Number = GLMeshNetworkModel.instance.nextK9Number(nodeAddress: node.primaryUnicastAddress)
            numberTF.text = "\(k9Number)"
            option = .onOff
            control = .click
            region = .light
            tasks.updateValue(true, forKey: .connect)
//            tasks.updateValue(control, forKey: .control)
            tasks.updateValue(option, forKey: .option)
        }
        let isEmergency = numberTF.text == "5"
        targetView.isUserInteractionEnabled = !isEmergency
        targetArrowImageView.isHidden = isEmergency
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageManager.delegate = self
    }
    
    @IBAction func controlAction(_ sender: Any) {
        let sheet = UIAlertController(title: "Control", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let clickAction = UIAlertAction(title: "Click", style: .default) { [weak self] _ in
            self?.control = .click
            self?.tasks.updateValue(self?.control, forKey: .control)
        }
        let longPressAction = UIAlertAction(title: "Long Press", style: .default) { [weak self] _ in
            self?.control = .longPress
            self?.tasks.updateValue(self?.control, forKey: .control)
        }
        let alwaysOnAction = UIAlertAction(title: "Always On", style: .default) { [weak self] _ in
            self?.control = .alwaysOn
            self?.tasks.updateValue(self?.control, forKey: .control)
        }
        sheet.addAction(clickAction)
        sheet.addAction(longPressAction)
        sheet.addAction(alwaysOnAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true)
    }
    
    @IBAction func optionAction(_ sender: UITapGestureRecognizer) {
        let sheet = UIAlertController(title: "Options", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let onOffAction = UIAlertAction(title: "ON/OFF", style: .default) { [weak self] _ in
            self?.option = .onOff
            self?.tasks.updateValue(self?.option, forKey: .option)
        }
        let emergencyAction = UIAlertAction(title: "Emergency", style: .default) { [weak self] _ in
            self?.option = .emergency
            self?.tasks.updateValue(self?.option, forKey: .option)
        }
        sheet.addAction(onOffAction)
        sheet.addAction(emergencyAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true)
    }
    
    @IBAction func regionAction(_ sender: UITapGestureRecognizer) {
        let sheet = UIAlertController(title: "Target", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let onOffAction = UIAlertAction(title: "Ligth", style: .default) { [weak self] _ in
            self?.region = .light
            self?.tasks.updateValue(self?.option, forKey: .option)
        }
        let emergencyAction = UIAlertAction(title: "Zone", style: .default) { [weak self] _ in
            self?.region = .zone
            self?.tasks.updateValue(self?.option, forKey: .option)
        }
        sheet.addAction(onOffAction)
        sheet.addAction(emergencyAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        view.endEditing(true)
        if let k9 {
            k9.name = nameTF.text ?? ""
            MeshNetworkManager.instance.saveAll()
        }
        if tasks.isEmpty { return }
        showHUD()
        doTasks()
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if let name = nameTF.text,
           !name.isEmpty,
           let number = numberTF.text,
           !number.isEmpty  {
            saveBtn.isEnabled = true
        } else {
            saveBtn.isEnabled = false
        }
    }
    
    @IBAction func numberChanged(_ sender: UITextField) {
        if let name = nameTF.text,
           !name.isEmpty,
           let number = numberTF.text,
           !number.isEmpty  {
            saveBtn.isEnabled = true
        } else {
            saveBtn.isEnabled = false
        }
        tasks[K9TaskType.connect] = true
        tasks.updateValue(option, forKey: .option)
        let isEmergency = sender.text == "5"
        region = isEmergency ? .zone : .light
        targetView.isUserInteractionEnabled = !isEmergency
        targetArrowImageView.isHidden = isEmergency
    }
    
    private func doTasks() {
        if tasks.values.compactMap({$0}).isEmpty {
            MeshNetworkManager.instance.saveAll()
            showSuccess() { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }
        let zone = GLMeshNetworkModel.instance.zone(node: node)
        guard let model = node.vendorModel else { return }
        if tasks[K9TaskType.connect] != nil {
            let k9Number = UInt8(numberTF.text ?? "1") ?? 1
            let message = GLK9ConnectMessage(number: k9Number)
            _ = try? MeshNetworkManager.instance.send(message, to: model)
            
//            k9 = GLK9(name: nameTF.text ?? "", number: k9Number, nodeAddress: node.primaryUnicastAddress)
//            GLMeshNetworkModel.instance.add(k9: k9!)
//            tasks[K9TaskType.connect] = nil
//            Task {
//                try? await Task.sleep(nanoseconds: 500_000_000)
//                doTasks()
//            }
//            print("aaa: \(k9Number)")
//        } else if let control = tasks[K9TaskType.control] as? K9ControlType {
//            guard let k9 else { return }
//            let value = String(format: "0x%02d%02d", k9.number, control.rawValue)
//            let message = GLK9ControlMessage(value: value)
//            _ = try? MeshNetworkManager.instance.send(message, to: model)
//            k9.control = control.rawValue
//            tasks[K9TaskType.control] = nil
//            Task {
//                try? await Task.sleep(nanoseconds: 500_000_000)
//                doTasks()
//            }
//            print("aaa: \(value)")
        } else if let _ = tasks[K9TaskType.option] as? K9OptionsType {
            guard let k9 else { return }
            var regionValue = ""
            if region == .light {
                regionValue = "000"
            } else {
                regionValue = String(format: "D%02d", zone.number)
            }
            let option: K9OptionsType = k9.number == 5 ? .emergency : .onOff
            let value = String(format: "0x%02d%@%d", k9.number, regionValue, option.rawValue)
            let message = GLK9OptionMessage(value: value)
            _ = try? MeshNetworkManager.instance.send(message, to: model)
            k9.option = option.rawValue
            k9.zone = zone.number
            k9.target = region.rawValue
            tasks[K9TaskType.option] = nil
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                doTasks()
            }
            print("aaa: \(value)")
        }
    }
}

extension PK9DetailViewController: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: MeshAddress) {
        if message is GLControlStatus {
            let k9Number = UInt8(numberTF.text ?? "1") ?? 1
            k9 = GLK9(name: nameTF.text ?? "", number: k9Number, nodeAddress: node.primaryUnicastAddress)
            GLMeshNetworkModel.instance.add(k9: k9!)
            tasks[K9TaskType.connect] = nil
            doTasks()
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            failedToSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress,
                            error: Error) {
        showError(error)
    }
    
}
