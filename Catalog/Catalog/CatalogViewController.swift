import UIKit
import CoreData

class CatalogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CatalogCollectionViewCellDelegate, NSFetchedResultsControllerDelegate {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var catalogView: UIBarButtonItem!
  @IBOutlet weak var carouselView: UIBarButtonItem!
  @IBOutlet weak var selectButton: UIButton!
  
  var dresses = LocalData.getDresses()
  var currentCustomer: Customer!
  var region = [String]()
  var languageIndex: Int!
  
  let catalogSize = CGSize(width: 246, height: 416)
  let carouselSize = CGSize(width: 515, height: 850)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "" ,style: .plain, target: nil, action: nil)
    if languageIndex != 0 {
      selectButton.setTitle(LocalData.getLocalizationLabels(forElement: "selectButton")[languageIndex], for: .normal)
    }
    
    navigationItem.title = LocalData.getLocalizationLabels(forElement: "catalogTitle")[languageIndex]
    collectionView?.allowsMultipleSelection = true
    selectButton.isEnabled = false
    selectButton.alpha = 0.25
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = false
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dresses.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CatalogCollectionViewCell
    cell.cellDelegate = self
    
    let dress = dresses[indexPath.row]
    
    // Configure the cell
    cell.dressLabel.font = UIFont(name: "TrajanPro-Regular", size: 22)
    cell.dressLabel.text = dress.name.count > 1 ? dress.name[languageIndex] : dress.name[0]
    cell.dressImageView.image = UIImage(named: dress.imgName)
    
    return cell
  }
  
  func didPressZoomButton(_ sender: UIButton) {
    if let indexPath = getCurrentCellIndexPath(sender) {
      
      let zoomImageView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZoomImageView") as! ImageViewController
      zoomImageView.dress = dresses[indexPath.row].imgName + "_full"
      self.addChild(zoomImageView)
      zoomImageView.view.frame = self.view.frame
      self.view.addSubview(zoomImageView.view)
      zoomImageView.didMove(toParent: self)
    }
  }
  
  func getCurrentCellIndexPath(_ sender: UIButton) -> IndexPath? {
    let buttonPosition = sender.convert(CGPoint.zero, to: collectionView)
    if let indexPath: IndexPath = collectionView.indexPathForItem(at: buttonPosition) {
      return indexPath
    }
    return nil
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    dresses[indexPath.row].isSelected = true
    selectButton.isEnabled = true
    selectButton.alpha = 1
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    dresses[indexPath.row].isSelected = false
    if let indexPath = collectionView.indexPathsForSelectedItems {
      if indexPath.count <= 0 {
        selectButton.isEnabled = false
        selectButton.alpha = 0.25
      }
    }
  }
  
  @IBAction func viewButtonPressed(_ sender: UIBarButtonItem) {
    
    if sender == catalogView {
      
      let layout = UICollectionViewFlowLayout()
      layout.scrollDirection = .horizontal
      layout.itemSize = catalogSize
      layout.sectionInset = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 7)
      layout.minimumLineSpacing = 8.0
      layout.minimumInteritemSpacing = 8.0
      collectionView.setCollectionViewLayout(layout, animated: true)
      catalogView.image = UIImage(named: "mosaic_sel")
      carouselView.image = UIImage(named: "carousel")
    }
    if sender == carouselView {
      
      let layout = UICollectionViewFlowLayout()
      layout.scrollDirection = .horizontal
      layout.itemSize = carouselSize
      layout.sectionInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 40)
      layout.minimumLineSpacing = 40.0
      layout.minimumInteritemSpacing = 30.0
      collectionView.setCollectionViewLayout(layout, animated: true)
      catalogView.image = UIImage(named: "mosaic")
      carouselView.image = UIImage(named: "carousel_sel")
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "selectDresses"{
      
      if let indexPath = collectionView.indexPathsForSelectedItems {
        let destinationController = segue.destination as! SelectionViewController
        
        destinationController.languageIndex = languageIndex
        var dressesNames = [String]()
        
        for index in indexPath {
          destinationController.selectedDresses.append(dresses[index.row])
          dressesNames.append(dresses[index.row].name[0])
        }
        currentCustomer.dressesNames = (dressesNames as NSArray).componentsJoined(by: ",")
        destinationController.currentCustomer = currentCustomer
        destinationController.region = region
      }
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
