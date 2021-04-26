import UIKit

protocol AddItemExamplesTableViewShowcaseProvider: class {
    var showcase: [ItemCategory: [Item]] { get }
}

final class AddItemExamplesTableViewDataSource: NSObject, UITableViewDataSource {
    weak var showcaseSource: AddItemExamplesTableViewShowcaseProvider?

    private var showcaseKeys: [ItemCategory]? {
        guard let showcase = showcaseSource?.showcase else { return nil }
        let keys = Array(showcase.keys)
        return keys.sorted { $0.rawValue < $1.rawValue }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        showcaseSource?.showcase.keys.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = showcaseKeys?[section]
        return key?.pluralized
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let keys = showcaseKeys else { return 0 }
        let key = keys[section]
        return showcaseSource?.showcase[key]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AddItemExamplesTableViewCell()
        cell.backgroundColor = .green
        return cell
    }
}
