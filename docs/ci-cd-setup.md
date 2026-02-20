# CI/CD Setup Guide

This document covers how to configure GitHub Actions for deploying **anchan** to TestFlight and Firebase App Distribution.

---

## Overview

| Workflow | Trigger | Destination |
|---|---|---|
| `deploy-testflight.yml` | Push to `main` or manual | Apple TestFlight |
| `deploy-firebase.yml` | Push to `develop` / `release/**` or manual | Firebase App Distribution |

---

## Prerequisites

- Apple Developer account with App Store Connect access
- Firebase project with App Distribution enabled
- Code signing certificate (`.p12`) and provisioning profile (`.mobileprovision`)

---

## Step 1: Code Signing Certificates

### Export Distribution Certificate
1. Open **Keychain Access** on your Mac
2. Find your **Apple Distribution** certificate
3. Right-click → **Export** → save as `.p12` with a password
4. Encode to base64:
   ```bash
   base64 -i certificate.p12 | pbcopy
   ```
5. Save the output as `CERTIFICATE_BASE64` secret

### Export Ad Hoc Certificate (for Firebase)
- Same steps as above using your **iOS Distribution** or **Apple Development** certificate
- Save as `CERTIFICATE_BASE64_ADHOC` secret

---

## Step 2: Provisioning Profiles

### App Store Profile (TestFlight)
1. Go to [Apple Developer Portal](https://developer.apple.com) → Certificates, IDs & Profiles
2. Create an **App Store** provisioning profile for bundle ID `com.codenour.anchan`
3. Download and encode:
   ```bash
   base64 -i anchan_appstore.mobileprovision | pbcopy
   ```
4. Save as `PROVISIONING_PROFILE_BASE64` secret

### Ad Hoc Profile (Firebase)
1. Create an **Ad Hoc** provisioning profile for `com.codenour.anchan`
2. Encode and save as `PROVISIONING_PROFILE_BASE64_ADHOC` secret

---

## Step 3: App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com) → Users and Access → Keys
2. Create a new API key with **App Manager** role
3. Download the `.p8` file (only downloadable once)
4. Encode the key content:
   ```bash
   base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
   ```
5. Note your **Key ID** and **Issuer ID** from the portal

---

## Step 4: Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com) → Project Settings → General
2. Find your **App ID** for the iOS app (format: `1:123456789:ios:abc123`)
3. Go to Project Settings → Service Accounts
4. Click **Generate new private key** → download the JSON file
5. Copy the entire JSON content

---

## Step 5: GitHub Secrets

Go to your GitHub repository → **Settings → Secrets and variables → Actions** and add:

### Required for TestFlight

| Secret | Description |
|---|---|
| `CERTIFICATE_BASE64` | Base64-encoded App Store `.p12` certificate |
| `CERTIFICATE_PASSWORD` | Password for the `.p12` certificate |
| `KEYCHAIN_PASSWORD` | Any secure random password for the temp keychain |
| `PROVISIONING_PROFILE_BASE64` | Base64-encoded App Store provisioning profile |
| `PROVISIONING_PROFILE_NAME` | Exact name of the provisioning profile |
| `APPLE_TEAM_ID` | Your Apple Developer Team ID (`K2C2F57T2L`) |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from App Store Connect |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | Issuer ID from App Store Connect |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Base64-encoded `.p8` key file content |

### Required for Firebase App Distribution

| Secret | Description |
|---|---|
| `CERTIFICATE_BASE64_ADHOC` | Base64-encoded Ad Hoc `.p12` certificate |
| `CERTIFICATE_PASSWORD` | Password for the `.p12` certificate (shared) |
| `KEYCHAIN_PASSWORD` | Temp keychain password (shared) |
| `PROVISIONING_PROFILE_BASE64_ADHOC` | Base64-encoded Ad Hoc provisioning profile |
| `PROVISIONING_PROFILE_NAME_ADHOC` | Exact name of the Ad Hoc provisioning profile |
| `APPLE_TEAM_ID` | Your Apple Developer Team ID |
| `FIREBASE_APP_ID` | Firebase iOS App ID |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Full JSON content of the Firebase service account key |

---

## Step 6: Firebase Tester Groups

In Firebase Console → App Distribution → Testers & Groups:
1. Create a group named `internal-testers`
2. Add tester emails to the group
3. You can add more groups and specify them in the workflow dispatch input

---

## Usage

### Deploy to TestFlight
- **Automatic**: Push to `main` branch
- **Manual**: Go to Actions → "Deploy to TestFlight" → Run workflow

### Deploy to Firebase
- **Automatic**: Push to `develop` or any `release/*` branch
- **Manual**: Go to Actions → "Deploy to Firebase App Distribution" → Run workflow
  - Optionally set release notes and tester groups

---

## Build Number

Build number is automatically set to the GitHub Actions **run number** (`${{ github.run_number }}`), which increments with each workflow run. This ensures Apple and Firebase always receive a unique, incrementing build number.

---

## Troubleshooting

### Code signing errors
- Verify the certificate and provisioning profile are not expired
- Ensure the provisioning profile matches the bundle ID `com.codenour.anchan`
- Check that the provisioning profile includes the UDID of test devices (Ad Hoc)

### Upload failures
- **TestFlight**: Verify the App Store Connect API key has `App Manager` role
- **Firebase**: Ensure the service account has `Firebase App Distribution Admin` role in IAM

### Build failures
- Check the "failed-archive" artifact uploaded on failure for detailed logs
- Run locally with the same `xcodebuild` command to reproduce
