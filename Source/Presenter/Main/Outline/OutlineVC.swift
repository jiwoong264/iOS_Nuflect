//
//  OutlineVC.swift
//  iOS_Nuflect
//
//  Created by Jiwoong's MacBook Air on 3/19/24.
//

import UIKit
import SnapKit

class OutlineVC: UIViewController {
    //MARK: - Properties
    lazy var formatText : String = ""
    lazy var purposeText : String = ""
    
    //will get from API
    lazy var paragraphs : [[String:String]] = []
    //is each paragrapgh written
    lazy var isWritten : [Bool] = []
    
    //MARK: - UI ProPerties
    lazy var navigationBar = UINavigationBar()
    
    //outline title
    lazy var outlineTitle: UILabel = {
        let label = UILabel()
        label.text = "추천받은 Outline을 기반으로\n단락별로 글을 작성해주세요"
        label.numberOfLines = 2
        label.font = UIFont.Nuflect.headtitlebold
        
        return label
    }()
    
    //outline collectionView
    lazy var outlineCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    //complete button
    lazy var completeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.Nuflect.lightGray
        button.layer.cornerRadius = 11
        
        button.setTitle("작성 완료", for: .normal)
        button.setTitleColor(UIColor.Nuflect.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.Nuflect.subheadMedium
        
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Define Method
    @objc func backButtonTapped() {
        print("back tapped")
        navigationController?.popViewController(animated: true)
    }
    
    @objc func mypageButtonTapped() {
        print("mypage tapped")
    }
    
    @objc func completeButtonTapped() {
        print("complete tapped")
        callPostAPI()
    }
    
    func callPostAPI() {
        print("post writing")
        let postMyWriting = PostMyWriting(format: formatText, purpose: purposeText, paragraphs: paragraphs)
        
        let body = [
            "format": postMyWriting.format as Any,
            "purpose" : postMyWriting.purpose as Any,
            "paragraphs" : postMyWriting.paragraphs as Any
        ] as [String: Any]
        
        APIManger.shared.callPostRequest(baseEndPoint: .myWriting, addPath: "", parameters: body) { JSON in
            do {
                // Convert JSON data to Swift objects
                if let jsonArray = try JSONSerialization.jsonObject(with: JSON["paragraphs"].rawData(), options: []) as? [[String: Any]] {
                    print(jsonArray)
                    // Now jsonArray is of type [[String: String]]
                    
                    let VC = CompleteVC()
                    VC.pkWriting = JSON["pk"].intValue
                    VC.formatText = self.formatText
                    VC.purposeText = self.purposeText
                    VC.paragraphs = jsonArray
                    self.navigationController?.pushViewController(VC, animated: true)
                }
            } catch {
                print("Error converting JSON to Swift objects: \(error)")
            }
        }
    }
    
    func checkAllparagraphsIsWritten() {
        print("check all")
        for bool in isWritten {
            if !bool {
                print("false")
                return
            }
        }
        print("true")
        completeButton.backgroundColor = .Nuflect.mainBlue
        completeButton.setTitleColor(.Nuflect.white, for: .normal)
        completeButton.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setConstraint()
        for _ in 0 ..< paragraphs.count {
            self.isWritten.append(false)
        }
    }
    
    //MARK: - Set Ui
    func setView() {
        setNavigationBar()
        addSubView()
        setCollectionView()
        self.view.backgroundColor = UIColor.Nuflect.white
    }
    
    func setNavigationBar() {
        let navigationItem = UINavigationItem()
        
        //back (left)
        let back = UIImage(systemName: "chevron.backward")
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 20, height: 20), false, 0.0)
        back?.draw(in: CGRect(x: 0, y: 0, width: 20, height: 20))
        let resizedBack = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let backImage = resizedBack?.withRenderingMode(.alwaysOriginal)

        let leftButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))

        navigationItem.leftBarButtonItem = leftButton
        
        navigationBar.setItems([navigationItem], animated: false)
        navigationBar.barTintColor = .Nuflect.white // 배경색 변경
        navigationBar.tintColor = .clear
        navigationBar.shadowImage = UIImage() // 테두리 없애기
    }
    
    func addSubView() {
        [outlineTitle, navigationBar, outlineCollectionView, completeButton].forEach { view in
            self.view.addSubview(view)
        }
    }
    
    //auto layout
    func setConstraint() {
        let leading = 35
        let top = 20
        
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(leading)
            make.trailing.equalToSuperview().offset(-leading)
        }
        
        outlineTitle.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(top)
            make.leading.equalToSuperview().offset(leading)
            make.trailing.equalToSuperview().offset(-leading)
        }
        
        outlineCollectionView.snp.makeConstraints { make in
            make.top.equalTo(outlineTitle.snp.bottom).offset(top)
            make.leading.equalToSuperview().offset(leading)
            make.trailing.equalToSuperview().offset(-leading)
            make.bottom.equalTo(completeButton.snp.top).offset(-top)
        }
        
        completeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(53)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-top)
        }
    }
}

//set collectionView and delegates
extension OutlineVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, moreOptionDelegate, returnToOutlineVCDelegate {
    //set collectionView
    func setCollectionView() {
        outlineCollectionView.backgroundColor = .Nuflect.white
        outlineCollectionView.dataSource = self
        outlineCollectionView.delegate = self
        registerCells()
    }
    
    func registerCells() {
        let cellIdentifiers = [
            "outlineCell": OutlineCell.self,
            "addCell": AddCell.self,
        ]

        cellIdentifiers.forEach { identifier, cellClass in
            outlineCollectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        paragraphs.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case paragraphs.count:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! AddCell
            
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outlineCell", for: indexPath) as! OutlineCell
            cell.delegate = self
            cell.paragraphNum = indexPath.item
            cell.paragraphTitleLabel.text = String(indexPath.item + 1) + ". " + paragraphs[indexPath.item]["index"]!
            
            if isWritten[indexPath.item] {
                cell.backgroundColor = UIColor.Nuflect.inputBlue
            }
            else {
                cell.backgroundColor = UIColor.Nuflect.white
            }
            
            return cell
        }
        
        
    }
    
    //cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = CGFloat(82)
        return CGSize(width: width, height: height)
    }
    
    
    
    //cell touch action
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        //last cell, add button
        case paragraphs.count:
            print("Add paragraph")
            let alert = UIAlertController(title: "단락 추가", message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "단락 이름을 입력하세요."
            }
            let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
                guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
                self?.addParagraph(title)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
            
            break
            
        default:
            print(indexPath.item)
            toWritingVC(cellNum: indexPath.item)
            break
        }
    }
    
    func toWritingVC(cellNum: Int) {
        let VC = WritingVC()
        VC.paragraphNum = cellNum
        VC.paragraphTitle = paragraphs[cellNum]["index"]!
        if self.isWritten[cellNum] {
            VC.writingTextView.text = paragraphs[cellNum]["content"]
            VC.writingTextView.textColor = UIColor.Nuflect.black
            VC.textViewDidEndEditing(VC.writingTextView)
        }
        navigationController?.pushViewController(VC, animated: true)
    }
    
    //for more option button
    func moreOptionTapped(cellNum: Int, selectedOption: String) {
        print(String(cellNum) + " " + selectedOption)
        switch selectedOption {
        case "단락 작성":
            toWritingVC(cellNum: cellNum)
            break
        case "이름 변경":
            let alert = UIAlertController(title: "이름 변경", message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "변경할 이름을 입력하세요."
            }
            let addAction = UIAlertAction(title: "변경", style: .default) { [weak self] _ in
                guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
                self?.renameParagraph(cellNum, title)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        case "순서 변경":
            let alert = UIAlertController(title: "순서 변경", message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "몇 번째 단락으로 변경할지 입력하세요."
                textField.keyboardType = .numberPad // 이 부분이 추가되었습니다.
            }
            let addAction = UIAlertAction(title: "변경", style: .default) { [weak self] _ in
                guard let numString = alert.textFields?.first?.text,
                      let num = Int(numString) else {
                        return
                    }
                self?.reorderParagraph(from: cellNum, to: num - 1)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        case "단락 삭제":
            let alert = UIAlertController(title: "\(cellNum + 1)번 단락을 삭제하시겠습니까?", message: nil, preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                self?.deleteParagraph(at: cellNum)
            }

            let cancelAction = UIAlertAction(title: "취소", style: .cancel)

            alert.addAction(deleteAction)
            alert.addAction(cancelAction)

            present(alert, animated: true)
            
        default:
            print("error")
        }
    }
    
    // Function to add a new paragraph
    func addParagraph(_ title: String) {
        paragraphs.append(["index": title, "content": ""])
        isWritten.append(false)
        outlineCollectionView.reloadData()
    }
    
    // Function to rename a new paragraph
    func renameParagraph(_ num: Int, _ title: String) {
        paragraphs[num]["index"] = title
        outlineCollectionView.reloadData()
    }
    
    // Function to delete a paragraph
    func deleteParagraph(at index: Int) {
        paragraphs.remove(at: index)
        isWritten.remove(at: index)
        outlineCollectionView.reloadData()
        checkAllparagraphsIsWritten()
    }
    
    // Function to reorder paragraphs
    func reorderParagraph(from sourceIndex: Int, to destinationIndex: Int) {
        if destinationIndex >= paragraphs.count || destinationIndex < 0 {
            let alert = UIAlertController(title: "1 ~ \(paragraphs.count) 사이의 숫자를 입력해주세요", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default)
            
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
        
        let movingParagraph = self.paragraphs[sourceIndex]
        let movingIsWritten = self.isWritten[sourceIndex]
        
        paragraphs.remove(at: sourceIndex)
        isWritten.remove(at: sourceIndex)
        
        paragraphs.insert(movingParagraph, at: destinationIndex)
        isWritten.insert(movingIsWritten, at: destinationIndex)
        outlineCollectionView.reloadData()
    }
    
    //for end writing a paragraph
    func returnToOutlineVC(paragraghNum: Int, paragraphContents: String) {
        print(String(paragraghNum))
        print(paragraphContents)
        
        self.isWritten[paragraghNum] = true
        self.paragraphs[paragraghNum]["content"] = paragraphContents
        
        outlineCollectionView.reloadData()
        checkAllparagraphsIsWritten()
    }
}
