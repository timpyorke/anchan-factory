import SwiftUI
import SwiftData
import PhotosUI
import Combine

struct ManufacturingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StackRouter.self) private var stackRouter

    let id: PersistentIdentifier

    @State private var viewModel = ManufacturingViewModel()
    @State private var stepNote: String = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showPhotoSourceOptions = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var cameraImage: Data?
    @State private var previewImage: Data?
    @State private var parallelStepNotes: [Int: String] = [:]
    @State private var currentStepIndexForPhoto: Int?

    var body: some View {
        Group {
            if let manufacturing = viewModel.manufacturing {
                if manufacturing.isCompleted {
                    ManufacturingCompletedView(
                        manufacturing: manufacturing,
                        viewModel: viewModel,
                        previewImage: $previewImage,
                        showCamera: $showCamera,
                        showPhotoLibrary: $showPhotoLibrary,
                        selectedPhotos: $selectedPhotos,
                        currentStepIndexForPhoto: $currentStepIndexForPhoto,
                        stackRouter: stackRouter
                    )
                } else {
                    ManufacturingStepView(
                        manufacturing: manufacturing,
                        viewModel: viewModel,
                        stepNote: $stepNote,
                        previewImage: $previewImage,
                        showCamera: $showCamera,
                        showPhotoLibrary: $showPhotoLibrary,
                        selectedPhotos: $selectedPhotos,
                        parallelStepNotes: $parallelStepNotes,
                        currentStepIndexForPhoto: $currentStepIndexForPhoto
                    )
                }
            } else {
                ContentUnavailableView(String(localized: "Not Found"), systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(viewModel.manufacturing?.recipe.name ?? String(localized: "Manufacturing"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if viewModel.manufacturing?.isCompleted == false {
                    Button {
                        viewModel.showExitOptions = true
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                if viewModel.manufacturing?.isCompleted == true {
                    Button(String(localized: "Done")) {
                        stackRouter.pop()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .confirmationDialog(String(localized: "Exit Manufacturing"), isPresented: $viewModel.showExitOptions, titleVisibility: .visible) {
            Button(String(localized: "Save & Exit")) {
                stackRouter.pop()
            }
            Button(String(localized: "Cancel Manufacturing"), role: .destructive) {
                viewModel.showCancelAlert = true
            }
            Button(String(localized: "Keep Working"), role: .cancel) { }
        } message: {
            Text(String(localized: "Your progress is automatically saved. You can continue later."))
        }
        .alert(String(localized: "Cancel Manufacturing"), isPresented: $viewModel.showCancelAlert) {
            Button(String(localized: "Go Back"), role: .cancel) { }
            Button(String(localized: "Cancel Manufacturing"), role: .destructive) {
                viewModel.cancelManufacturing {
                    stackRouter.pop()
                }
            }
        } message: {
            Text(String(localized: "Are you sure you want to cancel? This will mark the batch as cancelled and cannot be undone."))
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker(imageData: $cameraImage)
                .ignoresSafeArea()
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext, id: id)
            
            // Initialize notes from existing data
            if let manufacturing = viewModel.manufacturing {
                for log in manufacturing.stepLogs {
                    parallelStepNotes[log.stepIndex] = log.note
                }
            }
        }
        .overlay {
            if let imageData = previewImage, let uiImage = UIImage(data: imageData) {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                previewImage = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: previewImage != nil)
        .photosPicker(isPresented: $showPhotoLibrary, selection: $selectedPhotos, matching: .images)
        .onChange(of: selectedPhotos) { _, newValue in
            // Handle global selectedPhotos change
            if currentStepIndexForPhoto == nil && !newValue.isEmpty {
                Task {
                    for item in newValue {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            viewModel.addImageData(data, stepIndex: nil)
                        }
                    }
                    selectedPhotos = []
                }
            }
        }
        .onChange(of: cameraImage) { _, newValue in
            if let newValue {
                viewModel.addImageData(newValue, stepIndex: currentStepIndexForPhoto)
                cameraImage = nil
                currentStepIndexForPhoto = nil
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("Manufacturing Preview")
    }
    .modelContainer(AppModelContainer.make())
}
