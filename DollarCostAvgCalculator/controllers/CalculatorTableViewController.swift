//
//  CalculatorTableViewController.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/26/22.
//

import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {
    
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var investmentAmountLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var yeildLabel:  UILabel!
    @IBOutlet weak var annualReturnLabel: UILabel!
    
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var investmentCurrencyLabels: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    
    @IBOutlet weak var dateSlider: UISlider!
    
    var asset: Asset?
    
    @Published private var initialDateOfInvestmentIndex: Int?
    @Published private var initialInvestmentAmount: Int?
    @Published private var monthlyDollarCostAvgeragingAmount: Int?
    
    private var subscribers = Set<AnyCancellable>()
    
    private let dcaService = DCAService()
    private let calculatorPresenter =  CalculatorPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        setupTextFields()
        setupDateSlider()
        observeForm()
    }
    
    private func setupViews() {
        navigationItem.title = asset?.searchResultItem.symbol
        symbolLabel.text = asset?.searchResultItem.symbol
        companyLabel.text =  asset?.searchResultItem.name
        investmentCurrencyLabels.text = asset?.searchResultItem.currency  // no Parenthes
        
        currencyLabels.forEach{ (label) in
            label.text = asset?.searchResultItem.currency.addParentheses()   // addParen... via Extension on  String
        }
    }
    
    private func setupTextFields() {
        initialInvestmentAmountTextField.addDoneButton()
        monthlyDollarCostAveragingTextField.addDoneButton()
        initialDateOfInvestmentTextField.delegate = self
    }
    
    private func setupDateSlider() {
        if let count =  asset?.timeSeriesMonthlyAdjusted.getMonths().count {
            let countOffset = count - 1
            dateSlider.maximumValue =  countOffset.floatValue
        }
            
    }
    private func observeForm() {
        
        
        $initialDateOfInvestmentIndex.sink  { [weak self]  (index) in
            guard let index = index else { return }
            self?.dateSlider.value = index.floatValue
            // sets  the  Label text
            if let dateString =
                self?.asset?.timeSeriesMonthlyAdjusted.getMonths()[index].date.MMMMYYYYFormat {
                self?.initialDateOfInvestmentTextField.text = dateString
            }
        }.store(in: &subscribers)
        
        //  listen for events on the TextField
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField).compactMap( {
            ($0.object as? UITextField)?.text
            
        } ).sink { [weak self]  (text)  in
            self?.initialInvestmentAmount = Int(text)  ?? 0
        }.store(in: &subscribers)
        
        //  listen for events on the TextField
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: monthlyDollarCostAveragingTextField).compactMap( {
            ($0.object as? UITextField)?.text
            
        } ).sink { [weak self] (text)  in
            self?.monthlyDollarCostAvgeragingAmount = Int(text)  ?? 0
        }.store(in: &subscribers)
        
        Publishers.CombineLatest3($initialInvestmentAmount, $monthlyDollarCostAvgeragingAmount, $initialDateOfInvestmentIndex).sink { [weak self] (initialInvestmentAmount, monthlyDollarCostAvgeragingAmount, initialDateOfInvestmentIndex) in
            
            guard let initialInvestmentAmount = initialInvestmentAmount,
                  let monthlyDollarCostAvgeragingAmount = monthlyDollarCostAvgeragingAmount,
                  let initialDateOfInvestmentIndex = initialDateOfInvestmentIndex,
                  let asset = self?.asset
            else {
                return
            }

            guard let this = self else { return }
            
            let result = this.dcaService.calculate(asset: asset, initialInvestmentAmount: initialInvestmentAmount.doubleValue, monthlyDCAAmount: monthlyDollarCostAvgeragingAmount.doubleValue, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
            
            // update the labels from the calculation
            let presentation = this.calculatorPresenter.getPresentation(result: result)
                        
            this.currentAmountLabel.backgroundColor = presentation.currentValueLabelBackgroundColor
            this.currentAmountLabel.text = presentation.currentValue
            this.investmentAmountLabel.text = presentation.investmentAmount
            this.gainLabel.text = presentation.gain
            this.yeildLabel.text = presentation.yield
            this.yeildLabel.textColor = presentation.yieldLabelTextColor
            this.annualReturnLabel.text = presentation.annualReturn
            this.annualReturnLabel.textColor = presentation.annualReturnLabelTextColor
            
        }.store(in: &subscribers)
    }
    
    // showDateSelection
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "showDateSelection",
           let dateSelectionTableViewController = segue.destination as?  DateSelectionTableViewController,
           let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted {
            dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
            dateSelectionTableViewController.selectedIndex  =  initialDateOfInvestmentIndex
            dateSelectionTableViewController.didSelectDate = { [weak self] index in
                self?.handleDateSelection(at: index)
            }
        }
        
    }
    
    private func handleDateSelection(at  index: Int) {
        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
       
        navigationController?.popViewController(animated: true)
        
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonths()  {
            initialDateOfInvestmentIndex  = index
            let monthInfo =  monthInfos[index]
            let dateString = monthInfo.date.MMMMYYYYFormat
            
            initialDateOfInvestmentTextField.text =  dateString
        }
    }
    
    @IBAction func dateSliderDidChange(_ sender: UISlider) {
        initialDateOfInvestmentIndex = Int(sender.value)
    }
}


extension  CalculatorTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == initialDateOfInvestmentTextField {
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
            return  false  // dont show the keyboard
        }
        return true
    }
}
