require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class AbstractTarget

        def add_coverage_script_phase
          if shell_script_build_phases.select { |e| e.name == "CodeCoverageScripts" }.length < 1
            codeCoverageScript = new_shell_script_build_phase()
            codeCoverageScript.name = "CodeCoverageScripts"
            codeCoverageScript.shell_path = "/bin/bash"
            codeCoverageScript.shell_script = "${SRCROOT}/XcodeCoverage/exportenv.sh"
          end
        end
      end
    end
  end
end