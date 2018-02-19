
import UIKit
import CoreLocation
import CoreData

class LocationDetailsViewController: UITableViewController, CategoryPickerViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    private var descriptionText = " "
    private var category = "No Category"
    private var latitude: Double
    private var longitude: Double
    private var date = Date()
    private var address: String
    private var locationToEdit: Location?
    private var imageChanged = false
    private var image: UIImage? {
        didSet {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! SelectViaViewTableViewCell
            cell.show(image: image!)
            tableView.reloadData()
        }
    }

    private var observer: Any?

    //core data
    var managedObjectContext: NSManagedObjectContext!

    init(location: CLLocation, address: String) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.address = address
        super.init(style: .grouped)
    }

    init(locationToEdit: Location) {
        self.locationToEdit = locationToEdit
        self.descriptionText = locationToEdit.locationDescription
        self.category = locationToEdit.category
        self.date = locationToEdit.date!
        self.latitude = locationToEdit.latitude
        self.longitude = locationToEdit.longitude
        self.address = locationToEdit.address
        super.init(style: .grouped)
    }

    deinit {
        print("*** deinit \(self)")
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: "textViewCell")
        tableView.register(SelectViaViewTableViewCell.self, forCellReuseIdentifier: "selectViaViewCell")
        tableView.register(DoubleLabelTableViewCell.self, forCellReuseIdentifier: "doubleLabelCell")

        //gesture recogniser to hide keyboard when user clicks off textView cell
        let gestureRecognizer = UITapGestureRecognizer(target: self,  action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        if locationToEdit == nil {
            title = "Add Location"
        } else {
            title = "Edit Location"
            if image == nil, locationToEdit!.hasPhoto {
                if let theImage = locationToEdit!.photoImage {
                    self.image = theImage
                }
            }
        }
    }

    @objc func doneTapped() {
        //play animation
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        let location: Location

        if locationToEdit == nil {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
        } else {
            hudView.text = "Updated"
            location = locationToEdit!
        }

        //coreData object
        location.locationDescription = self.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        location.category = self.category
        location.latitude = self.latitude
        location.longitude = self.longitude
        location.date = self.date
        location.address = self.address
        location.photoID = nil
        // Save image
        if var image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            //only shrink the image if it has been changed
            if imageChanged {
                image = image.resized(withBounds:  CGSize(width: 260, height: 260))
            }
            if let data =  UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        do {
            // save coreData
            try managedObjectContext.save()
            //delay view dismiss so animation has time to play
            let delayInSeconds = 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds,
            execute: {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            })
        } catch {
            fatalCoreDataError(error)
        }
    }

    @objc func cancelTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    //function to hide keyboard when user clicks off textView cell
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        guard indexPath == nil || indexPath!.section != 0 || indexPath!.row != 0 else { return }

        resignTextViewResponse()
    }

    func resignTextViewResponse() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0) ) as! TextViewTableViewCell
        cell.textView.resignFirstResponder()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        if section == 1 {
           return 1
        }
        if section == 2 {
            return 4
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case  (0, 0) :
            return 88
        case  (1, 0) :
            return image == nil ? 44 : 280
        default:
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let label = UILabel()

        label.frame = CGRect(x: 10, y: 0, width: view.bounds.width, height: 30)
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 17)

        if section == 0 {
            label.text = "DESCRIPTION"
        }
        if section == 1 {
            label.text = "PHOTO"
        }
        if section == 2 {
            label.text = "LOCATION DETAILS"
        }

        headerView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        headerView.addSubview(label)
        return headerView
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        switch (indexPath.section, indexPath.row) {
        case  (0, 0) :
            let cell = tableView.cellForRow(at: indexPath) as! TextViewTableViewCell
            cell.textView.becomeFirstResponder()
        case  (0, 1) :
            let categoryPickerViewController = CategoryPickerViewController(category: self.category)
            categoryPickerViewController.delegate = self
            navigationController?.pushViewController(categoryPickerViewController, animated: true)
        case (1, 0) :
            self.pickPhoto()
        default:
            break
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        var cell: UITableViewCell?

        switch section {
        case 0:
            if row == 0 {
                cell = configureTextViewViewCell(indexPath: indexPath)
            }
            else if row == 1 {
                cell = configureSelectViaViewCell(indexPath: indexPath)
            }
        case 1:
            cell = configureSelectViaViewCell(indexPath: indexPath)
        case 2:
            cell = configureDoubleLabelCell(indexPath: indexPath)
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }

        return cell!

    }

    func configureTextViewViewCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! TextViewTableViewCell
        cell.textView.delegate = self
        if locationToEdit != nil {
            cell.textView.text = self.descriptionText
        }
        return cell
    }

    func configureSelectViaViewCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectViaViewCell", for: indexPath) as! SelectViaViewTableViewCell
        switch indexPath.section {
        case 0:
            cell.mainLabel.text = "Category"
            cell.selectedLabel.text = category
        case 1:
            cell.mainLabel.text = "Add Photo"
        default:
            break
        }
        return cell
    }

    func configureDoubleLabelCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "doubleLabelCell", for: indexPath) as! DoubleLabelTableViewCell
        switch indexPath.row {
        case 0:
            cell.leftLabel.text = "Latitude"
            cell.rightLabel.text = String(format: "%.8f", self.latitude)
        case 1:
            cell.leftLabel.text = "Longitude"
            cell.rightLabel.text = String(format: "%.8f",self.longitude)
        case 2:
            cell.leftLabel.text = "Address"
            cell.rightLabel.numberOfLines = 0
            cell.rightLabel.text = self.address
        case 3:
            cell.leftLabel.text = "Date"
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            cell.rightLabel.text = formatter.string(from: self.date)
        default:
            break
        }
        cell.selectionStyle = .none
        return cell
    }

    //MARK:- CategoryPickerViewControllerDelegate Methods
    func backTapped(_ categoryViewController: CategoryPickerViewController, selectedCategory: String) {
        self.category = selectedCategory
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }

    //MARK:- TextViewDelegate Methods
    func textViewDidChange(_ textView: UITextView) {
        self.descriptionText = textView.text
    }

    //MARK:- App State Listeners
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidEnterBackground,
        object: nil, queue: OperationQueue.main) { [weak self]_ in

            if let weakSelf = self {
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: false, completion: nil)
                }
                weakSelf.resignTextViewResponse()
            }
        }
    }
}

extension LocationDetailsViewController:
    UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }

    func showPhotoMenu() {

        let alert: UIAlertController

        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.takePhotoWithCamera() })
        alert.addAction(actPhoto)
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.choosePhotoFromLibrary() })
        alert.addAction(actLibrary)

        present(alert, animated: true, completion: nil)

    }

    // MARK:- Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        imageChanged = true
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
