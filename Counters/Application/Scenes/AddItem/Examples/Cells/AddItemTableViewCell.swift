import UIKit

final class AddItemTableViewCell: UITableViewCell {

    private struct Constants {
        static let leftSpacing: CGFloat = 15
        static let rightSpacing: CGFloat = 15
        static let height: CGFloat = 58
    }

    // MARK: - Public properties

    var showcase: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    weak var selectItemDelegate: AddItemExamplesDelegate? {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Private properties

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        selectionStyle = .none
        backgroundColor = .clear
        configureCollectionView()
    }

    // MARK: - Subviews

    private func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.registerReusable(AddItemCollectionViewCell.self)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.leftSpacing
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.rightSpacing
            ),
            collectionView.heightAnchor.constraint(equalToConstant: Constants.height)
        ])
    }
}

extension AddItemTableViewCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        showcase.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: AddItemCollectionViewCell = collectionView.dequeueReusable(for: indexPath)
        cell.title = showcase[indexPath.item]
        return cell
    }
}

extension AddItemTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let title = showcase[indexPath.item]
        selectItemDelegate?.userDidChooseExample(title: title)
    }
}

extension AddItemTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let genericCell = self.collectionView(collectionView, cellForItemAt: indexPath)
        guard let cell = genericCell as? AddItemCollectionViewCell else {
            return .zero
        }
        let itemSize = cell.itemSize
        return CGSize(width: itemSize.width, height: Constants.height)
    }
}
