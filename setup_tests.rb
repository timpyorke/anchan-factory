require 'xcodeproj'
require 'fileutils'

project_path = 'DailyJolly.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find main target
main_target = project.targets.find { |t| t.name == 'DailyJolly' }
if main_target.nil?
  puts "Could not find DailyJolly target."
  exit 1
end

# Check if tests target already exists
test_target_name = 'DailyJollyTests'
if project.targets.any? { |t| t.name == test_target_name }
  puts "Test target already exists."
  exit 0
end

# Add the test target
test_target = project.new_target(:unit_test_bundle, test_target_name, :ios)
project.targets << test_target

# Configure build settings (often required for tests)
test_target.build_configurations.each do |config|
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/DailyJolly.app/DailyJolly'
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.codenour.anchan.DailyJollyTests'
  config.build_settings['INFOPLIST_FILE'] = 'DailyJollyTests/Info.plist'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
end

# Add target dependency
test_target.add_dependency(main_target)

# Create physical directory
test_dir = File.join(Dir.pwd, test_target_name)
FileUtils.mkdir_p(test_dir)

# Create a group in Xcode
main_group = project.main_group
test_group = main_group.new_group(test_target_name, test_target_name)

# Create a basic Info.plist
info_plist_path = File.join(test_dir, 'Info.plist')
File.write(info_plist_path, <<-XML)
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
</dict>
</plist>
XML

# Add Info.plist to the project (but not to a build phase)
test_group.new_reference('Info.plist')

# Create a dummy test file
test_file_name = 'DailyJollyTests.swift'
test_file_path = File.join(test_dir, test_file_name)
File.write(test_file_path, <<-SWIFT)
import XCTest
@testable import DailyJolly

final class DailyJollyTests: XCTestCase {
    func testExample() throws {
        XCTAssertTrue(true)
    }
}
SWIFT

# Add the test file to Xcode and build phase
test_file_ref = test_group.new_reference(test_file_name)
test_target.source_build_phase.add_file_reference(test_file_ref)

# Add to the shared scheme so 'xcodebuild test' runs it
scheme_path = Xcodeproj::XCScheme.shared_data_dir(project_path)
scheme_file = File.join(scheme_path, 'DailyJolly.xcscheme')

if File.exist?(scheme_file)
  scheme = Xcodeproj::XCScheme.new(scheme_file)
  
  test_action = scheme.test_action
  
  # Ensure TestAction exists
  if test_action.nil?
    test_action = Xcodeproj::XCScheme::TestAction.new(test_target)
    scheme.test_action = test_action
  end
  
  # Add testable reference
  testable_ref = Xcodeproj::XCScheme::TestAction::TestableReference.new(test_target)
  test_action.add_testable(testable_ref)
  
  scheme.save!
  puts "Added test target to shared scheme."
end

project.save
puts "Successfully added DailyJollyTests target."
