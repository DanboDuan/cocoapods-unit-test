require 'xcodeproj'
require 'rubygems'
require "json"
require 'neatjson'

module Pod
  class TestResult
    attr_accessor :cov_path
    attr_accessor :json_path

    def initialize(json_path, cov_path)
      @json_path = File.expand_path(json_path)
      @cov_path = File.expand_path(cov_path)
    end

    def parse_json_result
      ## build_success, tests_count, tests_failed_count
      load_json_from_file.fetch("metrics", {}).tap { |result|
        UI.puts "Test case count :" + result.fetch("testsCount", {}).fetch("_value", 0).to_s
        UI.puts "Test case fail count :" + result.fetch("testsFailedCount", {}).fetch("_value", 0).to_s

        result.fetch("issues", {}).fetch("errorSummaries", {}).fetch("_values", []).each { |issues|
          UI.puts "❌ #{issues.fetch("issueType", {}).fetch("_value", "").to_s} -> #{issues.fetch("message", {}).fetch("_value", "").to_s}"
        }

        result.fetch("issues", {}).fetch("testFailureSummaries", {}).fetch("_values", []).each { |issues|
          UI.puts "❌ #{issues.fetch("testCaseName", {}).fetch("_value", "").to_s} -> #{issues.fetch("message", {}).fetch("_value", "").to_s}"
        }
      }
    end

    def parse_cov_result
      ## line_cov fun_cov headerCovTableEntry
    end

    def parse
      parse_json_result
      parse_cov_result
    end

    def load_json_from_file
      if File.file?(json_path)
        json_file = File.open json_path
        return JSON.load json_file
      end
      {}
    end

    def dump_json_to_file(result, file)
      File.open(file,"w") do |w|
        w.write(JSON.neat_generate(result, sort:true, wrap:true, after_colon:1))
      end
    end

  end
end