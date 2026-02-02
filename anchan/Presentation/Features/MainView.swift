import SwiftUI

struct MainView: View {
    @State private var tabRouter = TabRouter()
    @State private var stackRouter = StackRouter()

    var body: some View {
        NavigationStack(path: $stackRouter.path) {
            TabView(selection: $tabRouter.selectedTab) {
                HomeView(
                    tabRouter: tabRouter,
                    stackRouter: stackRouter
                )
                .tabItem {
                    Label(AppTab.home.title, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

                RecipeView(stackRouter: stackRouter)
                    .tabItem {
                        Label(AppTab.recipe.title, systemImage: AppTab.recipe.icon)
                    }
                    .tag(AppTab.recipe)

                InventoryView()
                    .tabItem {
                        Label(AppTab.inventory.title, systemImage: AppTab.inventory.icon)
                    }
                    .tag(AppTab.inventory)

                SettingView()
                    .tabItem {
                        Label(AppTab.setting.title, systemImage: AppTab.setting.icon)
                    }
                    .tag(AppTab.setting)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .recipeDetail(let id):
                    RecipeDetailView(id: id)
                case .recipeEdit(let id):
                    RecipeEditView(id: id)
                case .recipeAdd:
                    RecipeEditView(id: nil)
                case .manufacturingList:
                    ManufacturingListView()
                case .manufacturingProcess(let id):
                    ManufacturingView(id: id)
                case .manufacturingDetail(let id):
                    ManufacturingDetailView(id: id)
                }
            }
        }
        .environment(stackRouter)
    }
}
