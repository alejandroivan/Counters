
enum MainViewItemAction {
    case increment
    case decrement
}

protocol MainViewItemCellDelegate: class {

    func mainViewCell(_ cell: MainViewItemCell, countAction: MainViewItemAction)

}
