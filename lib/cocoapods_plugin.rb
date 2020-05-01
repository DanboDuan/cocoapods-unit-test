require 'cocoapods-unit-test/command'
require 'cocoapods-unit-test/xcodeproj/test_action'
require 'cocoapods-unit-test/xcodeproj/native_target'
require 'cocoapods-unit-test/xcodeproj/build_configuration'
require 'cocoapods-unit-test/xcodeproj/project'

require 'cocoapods-core'
require 'xcodeproj'
require 'cocoapods'

module CocoapodsUnitTest

  def self.modify_build_settings(target, is_target)
    target.build_configurations.each {|config| config.coverage_build_settings = is_target}
    if is_target
      target.add_coverage_script_phase()
    end
  end

  def self.modify_schemes_settings(xcproj, test_specs)
    project_path = xcproj.path
    test_targets = xcproj.targets.select { |target| test_specs.include?(target.name.to_s) }

    Dir[File.join(project_path, 'xcuserdata', '**', 'xcschemes', '*.xcscheme')].select { |e| 
      !test_targets.select { |target|
        File.basename(e, '.xcscheme').start_with?("#{target.name.to_s}-Unit") 
      }.empty?
    }.each do |path|
      scheme = File.basename(path, '.xcscheme')
      puts "Check scheme: #{scheme}"
      scheme_targets = test_targets.select { |e| scheme.include?(e.name.to_s) }
      unless scheme_targets.empty?
        puts "Test scheme: #{scheme} with targets: " + scheme_targets.map { |e| e.name.to_s }.join(",")
        xcproj_scheme = Xcodeproj::XCScheme.new(file_path = path)
        testAction = xcproj_scheme.test_action
        testAction.code_coverage_enabled = true
        testAction.coverage_specified_targets = true
        scheme_targets.each { |e| testAction.add_coverage_target(e) }
        # xcproj_scheme.save!
        File.delete(path)
        xcproj_scheme.save_as(project_path, scheme)
      else
        File.delete(path)
      end
    end
  end

  Pod::HooksManager.register('cocoapods-unit-test', :post_install) do |context, user_options|
    project_path = File.dirname(context.pods_project.path)
    puts project_path
    Dir[File.join(project_path,"**" ,'xcshareddata', '**', 'xcschemes', '*.xcscheme')].select { |e| 
      e.include?("-Unit-")
    }.each do |path|
      puts "Clean Tests xcscheme #{File.basename(path, '.xcscheme')}"
      File.delete(path)
    end

    coverages = context.pods_project.unit_test_dependency_pods().select { |e| e == "XcodeCoverage"  }
    if coverages.empty?
      puts "can not find XcodeCoverage"
      next
    else
      puts "XcodeCoverage ready"
    end

    test_specs = user_options.fetch(:names,[])
    if test_specs.nil? || test_specs.empty?
      test_specs = context.pods_project.unit_test_dev_pods()
    end

    test_specs.each { |x|  puts "Test target: #{x.to_s}"}
    if test_specs.empty?
      puts "can not find Test targets"
      next
    end

    Dir["**/*.xcodeproj"].each do |path|
      xcproj = Xcodeproj::Project.open(path)
      xcproj.targets.each do |target| 
        CocoapodsUnitTest.modify_build_settings(target, test_specs.include?(target.name.to_s))
      end
      CocoapodsUnitTest.modify_schemes_settings(xcproj, test_specs)
      xcproj.save
    end
    
  end

end

