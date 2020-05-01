require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      # Encapsulates the information a specific build configuration referenced
      # by a {XCConfigurationList} which in turn might be referenced by a
      # {PBXProject} or a {PBXNativeTarget}.
      #
      class XCBuildConfiguration

        def coverage_build_settings=(flag)
          value = 'NO'
          value = 'YES' if flag
          
          build_settings['CLANG_ENABLE_CODE_COVERAGE'] = value
          build_settings['GCC_INSTRUMENT_PROGRAM_FLOW_ARCS'] = value
          build_settings['GCC_GENERATE_TEST_COVERAGE_FILES'] = value
        end

      end
    end
  end
end