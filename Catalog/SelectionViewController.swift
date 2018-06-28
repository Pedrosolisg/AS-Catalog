import UIKit
import CoreData

class SelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var weddingDateLabel: UILabel!
    @IBOutlet weak var dressesLabel: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backHomeScreen: UIBarButtonItem!
    @IBOutlet weak var stackSelection: UIStackView!
    
    var selectedDresses = [Dress]()
    var provCart: Customer!
    var languageIndex: Int!
    
    var titleLang: [String] = ["WYBRANE MODELE","SELECTED MODELS","MODELOS SELECCIONADOS"]
    var homeLang: [String] = ["POWRÓT","HOME","INICIO"]
    var nameLang: [String] = ["Imię:","Name:","Nombre:"]
    var lastnameLang: [String] = ["Nazwisko:","Lastname:","Apellidos:"]
    var hometownLang: [String] = ["Województwo:","Region:","Región:"]
    var weddingDateLang: [String] = ["Data Ślubu:","Wedd. Date:","Fecha Boda:"]
    var confirmLang: [String] = ["POTWIERDŹ WYBÓR","CONFIRM SELECTION","CONFIRMAR SELECCIÓN"]
    var regionNames = ["dolnośląskie", "kujawsko-pomorskie", "lubelskie", "lubuskie", "łódzkie", "małopolskie", "mazowieckie", "opolskie", "podkarpackie", "podlaskie", "pomorskie", "śląskie", "świętokrzyskie", "warmińsko-mazurskie", "wielkopolskie", "zachodniopomorskie"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "" ,style: .plain, target: nil, action: nil)
        nameLabel.text = nameLang[languageIndex] + " " + provCart.name
        lastnameLabel.text = lastnameLang[languageIndex] + " " + provCart.surname
        hometownLabel.text = hometownLang[languageIndex] + " " + provCart.region
        weddingDateLabel.text = weddingDateLang[languageIndex] + " " + provCart.dateOfWedding
        saveButton.setTitle(confirmLang[languageIndex], for: .normal)
        navigationItem.title = titleLang[languageIndex]
        backHomeScreen.title = homeLang[languageIndex]
        backHomeScreen.tintColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0)
        
        let maskPathSave = UIBezierPath(roundedRect: saveButton.bounds, byRoundingCorners: [.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 10.0, height: 10.0))
        
        let maskLayerSave = CAShapeLayer()
        maskLayerSave.path = maskPathSave.cgPath
        saveButton.layer.mask = maskLayerSave
        
        let maskPathLabel = UIBezierPath(roundedRect: dressesLabel.bounds, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: 10.0, height: 10.0))
        
        let maskLayerLabel = CAShapeLayer()
        maskLayerLabel.path = maskPathLabel.cgPath
        dressesLabel.layer.mask = maskLayerLabel
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as! SelectionTableViewCell
        let dress = selectedDresses[indexPath.row]
        
        cell.dressLabel.font = UIFont(name: "TrajanPro-Regular", size: 32)
        cell.dressLabel.text = dress.name
        cell.dressImageView.image = UIImage(named: dress.imgName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let popImageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectedDressView") as! SelectedDressViewController
        popImageView.dressImage = selectedDresses[indexPath.row].imgName
        self.addChildViewController(popImageView)
        popImageView.view.frame = self.view.frame
        self.view.addSubview(popImageView.view)
        popImageView.didMove(toParentViewController: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func clearAllVariables() {
        provCart = nil
        selectedDresses.removeAll()
        tableView = nil
    }
    
    func showCompleteView() {
        
        let popCompleteView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompleteView") as! CompleteViewController
        popCompleteView.languageIndex = self.languageIndex
        self.addChildViewController(popCompleteView)
        popCompleteView.view.frame = self.view.frame
        self.view.addSubview(popCompleteView.view)
        popCompleteView.didMove(toParentViewController: self)
    }
    
    @IBAction func saveSelectionToCart(_ sender: UIButton) {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            
            if Reachability.isConnectedToNetwork() {
                APIConnector.sendCostumerToAPI(customer: provCart) { (data, resp, error) in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                    print("error in BackEnd - Saving in Core Data")
                    CoreDataManager.saveCustomerInCoreData(customer: self.provCart, viewContext: appDelegate.persistentContainer.viewContext)
                    appDelegate.saveContext()
                }
            } else {
                print("NO INTERNET - Saving in Core Data")
                CoreDataManager.saveCustomerInCoreData(customer: provCart, viewContext: appDelegate.persistentContainer.viewContext)
                appDelegate.saveContext()
            }
            
            showCompleteView()
            sendCustomerBackToHomeScreen()
        }
    }
    
    @IBAction func backToHomeScreen(_ sender: UIBarButtonItem) {
        
        clearAllVariables()
        self.performSegue(withIdentifier: "unwindToHomeScreen", sender: self)
        self.dismiss(animated: false)
    }
    
    private func sendCustomerBackToHomeScreen() {
        saveButton.isEnabled = false
        saveButton.alpha = 0.25
        navigationItem.backBarButtonItem!.tintColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0)
        navigationItem.backBarButtonItem!.isEnabled = false
        backHomeScreen.tintColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        backHomeScreen.isEnabled = true
    }
}
