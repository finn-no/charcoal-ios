import FinniversKit

class FreeTextFilterSearchBar: UISearchBar {
    // Makes sure to setup appearance proxy one time and one time only
    private static let setupSearchQuerySearchBarAppereanceOnce: () = {
        let textFieldAppearanceInRoot = UITextField.appearance(whenContainedInInstancesOf: [AppearanceColoredTableView.self])
        textFieldAppearanceInRoot.adjustsFontForContentSizeCategory = true
        textFieldAppearanceInRoot.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.textAction,
            NSAttributedString.Key.font: UIFont.bodyRegular,
        ]

        let textFieldAppearanceInSearch = UITextField.appearance(whenContainedInInstancesOf: [FreeTextFilterSearchBar.self])
        textFieldAppearanceInRoot.adjustsFontForContentSizeCategory = true
        textFieldAppearanceInSearch.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.textPrimary,
            NSAttributedString.Key.font: UIFont.bodyRegular,
        ]

        let barButtondAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [FreeTextFilterSearchBar.self])
        barButtondAppearance.setTitleTextAttributes([.font: UIFont.bodyRegular])
        barButtondAppearance.title = "cancel".localized()
    }()

    override init(frame: CGRect) {
        _ = FreeTextFilterSearchBar.setupSearchQuerySearchBarAppereanceOnce
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        _ = FreeTextFilterSearchBar.setupSearchQuerySearchBarAppereanceOnce
        super.init(coder: aDecoder)
    }
}
