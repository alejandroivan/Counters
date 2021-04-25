import UIKit

final class MainTableViewDataSource: NSObject, UITableViewDataSource {
    var presenter: MainPresenter?

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        presenter?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = presenter?.items[indexPath.row].title
        return cell
    }
}
