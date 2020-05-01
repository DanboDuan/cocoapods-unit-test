require 'xcodeproj'
require 'rexml/document'

module Xcodeproj
  class XCScheme
    # This class wraps the TestAction node of a .xcscheme XML file
    #
    class TestAction

      def coverage_specified_targets?
        string_to_bool(@xml_element.attributes['onlyGenerateCoverageForSpecifiedTargets'])
      end

      # @param [Bool] flag
      def coverage_specified_targets=(flag)
        @xml_element.attributes['onlyGenerateCoverageForSpecifiedTargets'] = bool_to_string(flag)
      end

      # @param [BuildableReference] targets
      #
      def add_coverage_target_ref(ref)
        coverage_targets = @xml_element.elements['CodeCoverageTargets'] || @xml_element.add_element('CodeCoverageTargets')

        added = coverage_targets.get_elements('BuildableReference').map { |node|
          BuildableReference.new(node)
        }.select { |build| build.target_name == ref.target_name }
        
        if added.empty?
          coverage_targets.add_element(ref.xml_element)
        end
      end

      # @param [Xcodeproj::Project::Object::AbstractTarget] test_target
      # @param [Xcodeproj::Project] the root project to reference from
      #                             (when nil the project of the target is used)
      def add_coverage_target(target, root_project = nil)
        add_coverage_target_ref BuildableReference.new(target, root_project) unless target.nil?
      end

    end
  end

end