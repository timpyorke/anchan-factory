require 'xcodeproj'

project_path = 'DailyJolly.xcodeproj'
project = Xcodeproj::Project.open(project_path)

test_target = project.targets.find { |t| t.name == 'DailyJollyTests' }

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
  
  # Add testable reference if not already there
  if test_action.testables.none? { |t| t.target_referenced == test_target }
    testable_ref = Xcodeproj::XCScheme::TestAction::TestableReference.new(test_target)
    test_action.add_testable(testable_ref)
  end
  
  scheme.save!
  puts "Added test target to shared scheme."
end
