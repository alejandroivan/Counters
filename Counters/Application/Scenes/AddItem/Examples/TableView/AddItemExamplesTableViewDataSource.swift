import UIKit

protocol AddItemExamplesTableViewShowcaseProvider: class {
    var showcase: [ItemCategory: [String]] { get }
}

final class AddItemExamplesTableViewDataSource: NSObject, UITableViewDataSource {
    weak var showcaseSource: AddItemExamplesTableViewShowcaseProvider?
    weak var selectItemDelegate: AddItemExamplesDelegate?

    private var showcaseKeys: [ItemCategory]? {
        guard let showcase = showcaseSource?.showcase else { return nil }
        let keys = Array(showcase.keys)
        return keys.sorted { $0.rawValue < $1.rawValue }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        showcaseSource?.showcase.keys.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let key = showcaseKeys?[indexPath.section],
            let showcase = showcaseSource?.showcase[key]
        else {
            return UITableViewCell()
        }

        let cell: AddItemTableViewCell = tableView.dequeueReusable(for: indexPath)
        cell.showcase = showcase
        cell.selectItemDelegate = selectItemDelegate
        return cell
    }
}
