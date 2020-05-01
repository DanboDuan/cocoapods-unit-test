require 'cocoapods-unit-test/project'

module Pod
  class Command
    class Test < Command

      self.summary = 'Short description of cocoapods-unit-test.'
      self.command = 'test'
      self.description = <<-DESC
        Longer description of cocoapods-unit-test.
      DESC

      self.arguments = [
          CLAide::Argument.new('NAME', true),
        ]
      def self.options
        options = [
          ['--reinstall',    're pod install'],
          ["--simulator='SIMULATOR'",    "simulator name like 'iPhone 8'"],
        ]
        options.concat(super.reject { |option, _| option == '--silent' })
      end

      def initialize(argv)
        @simulator = argv.option('simulator', 'iPhone 8')
        @reinstall = argv.flag?('reinstall')
        @name = argv.shift_argument
        @project = TestProject.new(@name, @simulator)
        super
      end

      def validate!
        super
        help! 'A Pod name is required.' unless @name
        @project.validate!
      end

      def run
        UI.title "Runing Test..." do
          @project.run(@reinstall)
        end

        UI.title "Finish Test..."
        
      end
    end
  end
end
