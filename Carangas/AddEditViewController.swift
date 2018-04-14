//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var car: Car!
    
    var brands: [FIPE] = []
  
    
    var pickerView: UIPickerView!

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView = UIPickerView() //Instanciando o UIPickerView
        pickerView.backgroundColor = .white
        pickerView.delegate = self  //Definindo seu delegate
        pickerView.dataSource = self  //Definindo seu dataSource
        
        //Criando uma toobar que servirá de apoio ao pickerView. Através dela, o usuário poderá
        //confirmar sua seleção ou cancelar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        //O botão abaixo servirá para o usuário cancelar a escolha de gênero, chamando o método cancel
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //O botão done confirmará a escolha do usuário, chamando o método done.
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        //Aqui definimos que o pickerView será usado como entrada do extField
        tfBrand.inputView = pickerView
        
        //Definindo a toolbar como view de apoio do textField (view que fica acima do teclado)
        tfBrand.inputAccessoryView = toolbar
        
        
        if car != nil {
            tfName.text = car.name
            tfBrand.text = car.brand
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar", for: .normal)
            
        }
    }
    
    // MARK: - IBActions
    @IBAction func addEdit(_ sender: UIButton) {
        loading.startAnimating()
        sender.isEnabled = false
        sender.alpha = 0.5
        sender.backgroundColor = .gray
        
        if car == nil {
            car = Car()
        }
        car.brand = tfBrand.text!
        car.name = tfName.text!
        car.gasType = scGasType.selectedSegmentIndex
        car.price = Double(tfPrice.text!)!
        if car._id == nil {
            REST.saveCar(car, onComplete: { (success) in
                self.goBack()
            })
        } else {
            REST.updateCar(car, onComplete: { (success) in
                self.goBack()
            })
        }
        
    }
    func goBack() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBrands()
    }
    
    func loadBrands(){
        RESTFIPE.loadBrands(onComplete: { [weak self] (loadedBrands) in
            print("terminou!!!!!")
            self?.brands = loadedBrands
            DispatchQueue.main.async {
                self?.pickerView.reloadAllComponents()
                if let row = self?.brands.index(where: {$0.name == self!.tfBrand.text!}) {
                  self?.pickerView.selectRow(row, inComponent: 0, animated: true)
                }
            }
            
        }) { (error) in
            switch error{
            case .responseStatusCode(let code):
                print("Você recebeu o statusCod de código \(code)")
            default:
                print("Deu erro te vira")
            }
        }
        
    }
    
    //O método cancel irá esconder o teclado e não irá atribuir a seleção ao textField
    @objc func cancel() {
        
        //O método resignFirstResponder() faz com que o campo deixe de ter o foco, fazendo assim
        //com que o teclado (pickerView) desapareça da tela
        tfBrand.resignFirstResponder()
    }
    
    //O método done irá atribuir ao textField a escolhe feita no pickerView
    @objc func done() {
        
        //Abaixo, recuperamos a linha selecionada na coluna (component) 0 (temos apenas um component
        //em nosso pickerView)
        tfBrand.text = brands[pickerView.selectedRow(inComponent: 0)].name
    
        cancel()
    }
    
}


extension AddEditViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Retornando o texto recuperado do objeto dataSource, baseado na linha selecionada
        return brands[row].name
    }
}

extension AddEditViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    //Usaremos apenas 1 coluna (component) em nosso pickerView
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brands.count //O total de linhas será o total de itens em nosso dataSource
    }
}
