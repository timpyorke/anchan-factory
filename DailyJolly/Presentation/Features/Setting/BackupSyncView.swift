import SwiftUI
import SwiftData

struct BackupSyncView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BackupSyncViewModel()

    var body: some View {
        Form {
            accountSection
            if viewModel.isSignedIn {
                backupStatusSection
                autoBackupSection
                restoreSection
                disconnectSection
            }
        }
        .navigationTitle(String(localized: "Google Drive Backup"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
        .alert(String(localized: "Restore Backup"), isPresented: $viewModel.showRestoreConfirmation) {
            Button(String(localized: "Cancel"), role: .cancel) { }
            Button(String(localized: "Restore"), role: .destructive) {
                viewModel.confirmRestore()
            }
        } message: {
            if let file = viewModel.selectedBackupForRestore {
                Text(String(localized: "This will replace all existing data with \"\(file.name)\". This action cannot be undone."))
            }
        }
        .alert(String(localized: "Backup Restored"), isPresented: $viewModel.showRestoreSuccess) {
            Button(String(localized: "OK")) { }
        } message: {
            Text(String(localized: "Your data has been successfully restored from the backup."))
        }
        .alert(String(localized: "Error"), isPresented: $viewModel.showError) {
            Button(String(localized: "OK")) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        Section {
            if viewModel.isSignedIn {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "Connected"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(viewModel.userEmail ?? "")
                            .font(.body)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            } else {
                Button {
                    viewModel.signIn()
                } label: {
                    Label(String(localized: "Connect Google Account"), systemImage: "person.badge.plus")
                }
            }
        } header: {
            Text(String(localized: "Google Account"))
        } footer: {
            if !viewModel.isSignedIn {
                Text(String(localized: "Sign in with Google to back up your data to Google Drive."))
            }
        }
    }

    // MARK: - Backup Status Section

    private var backupStatusSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "Last Backup"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let date = viewModel.lastBackupDate {
                        Text(date, style: .relative)
                            .font(.body)
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(localized: "Never backed up"))
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }

            Button {
                viewModel.performBackup()
            } label: {
                HStack {
                    Label(String(localized: "Back Up Now"), systemImage: "icloud.and.arrow.up.fill")
                    if viewModel.isBackingUp {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(viewModel.isBackingUp)
        } header: {
            Text(String(localized: "Backup"))
        }
    }

    // MARK: - Auto Backup Section

    private var autoBackupSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { viewModel.autoBackupOnLaunch },
                set: { viewModel.autoBackupOnLaunch = $0 }
            )) {
                Label(String(localized: "Auto-backup on Launch"), systemImage: "arrow.clockwise.icloud")
            }
        } header: {
            Text(String(localized: "Automation"))
        } footer: {
            Text(String(localized: "Automatically back up your data each time the app opens."))
        }
    }

    // MARK: - Restore Section

    private var restoreSection: some View {
        Section {
            if viewModel.isLoadingBackups {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if viewModel.availableBackups.isEmpty {
                Text(String(localized: "No backups found"))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.availableBackups) { file in
                    Button {
                        viewModel.selectBackupForRestore(file)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(file.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                if let date = file.createdDate {
                                    Text(date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if viewModel.isRestoring {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(viewModel.isRestoring)
                }
            }
        } header: {
            Text(String(localized: "Restore from Backup"))
        } footer: {
            Text(String(localized: "Restoring will replace all current data. This cannot be undone."))
        }
    }

    // MARK: - Disconnect Section

    private var disconnectSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.signOut()
            } label: {
                Label(String(localized: "Disconnect Google Account"), systemImage: "person.badge.minus")
            }
        }
    }
}

#Preview {
    NavigationStack {
        BackupSyncView()
    }
    .modelContainer(AppModelContainer.make())
}
