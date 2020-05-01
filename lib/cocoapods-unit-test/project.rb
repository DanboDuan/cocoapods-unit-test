require 'xcodeproj'
require 'rubygems'
require 'cocoapods-unit-test/result'
require 'cocoapods-unit-test/xcodeproj/project'

module Pod
  class TestProject

    attr_accessor :path
    attr_accessor :podfile
    attr_accessor :pods_project
    attr_accessor :workspace
    attr_accessor :schemes
    attr_accessor :target
    attr_accessor :derived_data_path
    attr_accessor :destination
    attr_accessor :cov_shell

    def initialize(name, simulator, path = Dir.pwd)
      @destination = "platform=iOS Simulator,name=#{simulator}"
      @target = name
      @path = File.expand_path(path)
    end

    def podfile
      @podfile ||= File.expand_path("Podfile", path)
    end

    def workspace
      @workspace ||= begin
        ws = Dir["*.xcworkspace"].first
        raise Informative, "No xcworkspace" if ws.nil? || ws.empty?
        raise Informative, "No xcworkspace in #{path}" unless File.directory?(ws)
        File.expand_path(ws, path)
      end
    end

    def schemes
      @schemes ||= Dir[File.join(path, '**', 'xcschemes', '*.xcscheme')].select { |e| 
        e.include?("-Unit-")
      }.map {|scheme| 
        File.basename(scheme, '.xcscheme')
      }.select { |scheme|
        scheme.start_with?("#{target}-Unit")
      }
    end

    def pods_project
      @pods_project ||= begin
        pods = Dir["**/*.xcodeproj"].select { |e| e.end_with?("Pods.xcodeproj")  }
        raise Informative, "can not find Pods.xcodeproj" if pods.empty?
        pod = pods.first
        raise Informative, "can not find Pods.xcodeproj in #{path}" unless File.directory?(pod)
        File.expand_path(pod, path)
      end
    end

    def validate_target!
      project = Xcodeproj::Project.open(pods_project)
      return true if project.unit_test_dev_pods().include?(@target)
      return true if project.unit_test_dependency_pods().include?(@target)
      raise Informative, "can not find test target #{@target} in Pods.xcodeproj"
      return false
    end

    def derived_data_path
      @derived_data_path ||= File.expand_path("build/derivedDataPath", path)
    end

    def result_bundle_path(scheme)
      File.expand_path("build/#{scheme}/Test.xcresult", path)
    end

    def result_json_path(scheme)
      File.expand_path("build/#{scheme}/TestResult.json", path)
    end

    def destination
      @destination ||= "platform=iOS Simulator,name=iPhone 8"
    end

    def archives_path(scheme)
      File.expand_path("build/#{scheme}/archives", path)
    end

    def cov_shell
      @cov_shell ||= File.expand_path("Pods/XcodeCoverage/getcov", path)
    end

    def validate!
      raise Informative, "No Podfile!" unless File.file?(podfile)
      validate_target!
      raise Informative, "No Test schemes!" if schemes.empty?
    end

    def pod_install
      UI.puts "pod install..."
      raise Informative, "Please use a Gemfile or run pod install by yourself" unless File.file?("Gemfile")
      system( "bundle install")
      system( "bundle exec pod install")
      raise Informative, "XcodeCoverage not found" unless File.file?(cov_shell)
      raise Informative, "workspace not found" unless File.directory?(workspace)
    end

    def run_test_with_scheme(scheme)
      system("rm -fr #{result_bundle_path(scheme)}")
      system("rm -fr #{result_json_path(scheme)}")
      system("rm -fr #{archives_path(scheme)}")
      system("mkdir -p #{archives_path(scheme)}")

      cmd = %W(xcodebuild test -workspace #{workspace} -scheme #{scheme}  -UseModernBuildSystem=NO 
        -derivedDataPath #{derived_data_path} -resultBundlePath #{result_bundle_path(scheme)}) + [
        "-destination '#{destination}'",
        "| xcpretty",
      ]

      UI.puts cmd.join(" ")
      system(cmd.join(" "))

      cmd = %W(xcrun xcresulttool get --path #{result_bundle_path(scheme)} --format json) + [
        ">  #{result_json_path(scheme)}",
      ]
      UI.puts cmd.join(" ")
      system(cmd.join(" "))

      cmd = %W(#{cov_shell} -x -o #{archives_path(scheme)})
      UI.puts cmd.join(" ")
      system(cmd.join(" "))

      index_file = File.join(archives_path(scheme),"lcov/index.html")
      TestResult.new(result_json_path(scheme),index_file).parse()

      system("open #{index_file}") if File.file?(index_file)
    end

    def run_test
      UI.title "Test target: #{target}" do 
        schemes.each { |e| UI.puts "Test Schemes: #{e}" }
      end

      system( "rm -fr #{derived_data_path}")
      system( "mkdir -p #{derived_data_path}")

      schemes.each do |scheme|
        UI.puts "Testing #{scheme}..."
        run_test_with_scheme(scheme)
      end
    end


    def run(install_flag)
      pod_install if install_flag
      run_test
    end
  end
end