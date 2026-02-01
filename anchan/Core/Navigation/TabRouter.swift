import Observation

@Observable
final class TabRouter {

    var selectedTab: AppTab = .home

    func go(to tab: AppTab) {
        selectedTab = tab
    }
}
