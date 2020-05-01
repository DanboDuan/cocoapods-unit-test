require 'open3'
module Pod
  module UnitExecutable
    
    def executable(name)
      unless respond_to?("#{name.to_s}!")
        define_method(name.to_s + '!') do |*command|
          UnitExecutable.execute_command(name, Array(command).flatten, true)
        end
      end
      
    end

    def self.execute_command(executable, command, raise_on_failure = true)
      bin = which!(executable)

      command = command.map(&:to_s)
      if File.basename(bin) == 'tar.exe'
        # Tar on Windows needs --force-local
        command.push('--force-local')
      end
      full_command = "#{bin} #{command.join(' ')}"

      stdout = Indenter.new(STDOUT)
      stderr = Indenter.new(STDERR)

      status = popen3(bin, command, stdout, stderr)
      stdout = stdout.join
      stderr = stderr.join
      output = stdout + stderr
      unless status.success?
        UI.puts("$ #{full_command}")
        if raise_on_failure
          raise Informative, "#{full_command}\n\n#{output}"
        else
          UI.puts("[!] Failed: #{full_command}".red)
        end
      end

      output
    end

    def self.which(program)
      program = program.to_s
      paths = ENV.fetch('PATH') { '' }.split(File::PATH_SEPARATOR)
      paths.unshift('./')
      paths.uniq!
      paths.each do |path|
        bin = File.expand_path(program, path)
        if Gem.win_platform?
          bin += '.exe'
        end
        if File.file?(bin) && File.executable?(bin)
          return bin
        end
      end
      nil
    end

    def self.which!(program)
      which(program).tap do |bin|
        raise Informative, "Unable to locate the executable `#{program}`" unless bin
      end
    end

    def self.capture_command(executable, command, capture: :merge, env: {}, **kwargs)
      bin = which!(executable)
      command = command.map(&:to_s)
      case capture
      when :merge then Open3.capture2e(env, [bin, bin], *command, **kwargs)
      when :both then Open3.capture3(env, [bin, bin], *command, **kwargs)
      when :out then Open3.capture3(env, [bin, bin], *command, **kwargs).values_at(0, -1)
      when :err then Open3.capture3(env, [bin, bin], *command, **kwargs).drop(1)
      when :none then Open3.capture3(env, [bin, bin], *command, **kwargs).last
      end
    end

    def self.capture_command!(executable, command, **kwargs)
      capture_command(executable, command, **kwargs).tap do |result|
        result = Array(result)
        status = result.last
        unless status.success?
          output = result[0..-2].join
          raise Informative, "#{bin} #{command.join(' ')}\n\n#{output}".strip
        end
      end
    end

    private

    def self.popen3(bin, command, stdout, stderr)
      Open3.popen3(bin, *command) do |i, o, e, t|
        reader(o, stdout)
        reader(e, stderr)
        i.close

        status = t.value

        o.flush
        e.flush
        sleep(0.01)

        status
      end
    end

    def self.reader(input, output)
      Thread.new do
        buf = ''
        begin
          loop do
            buf << input.readpartial(4096)
            loop do
              string, separator, buf = buf.partition(/[\r\n]/)
              if separator.empty?
                buf = string
                break
              end
              output << (string << separator)
            end
          end
        rescue EOFError, IOError
          output << (buf << $/) unless buf.empty?
        end
      end
    end


    class Indenter < ::Array
      attr_reader :indent
      attr_reader :io

      def initialize(io = nil)
        @io = io
        @indent = ' ' * UI.indentation_level
      end

      def <<(value)
        super
        io << "#{indent}#{value}" if io
      end
    end


  end
end