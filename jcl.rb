require 'ext/string'

module Jcl
  
  CHARSET_NAME    = '[A-Z0-9@#]+'
  # JOB文にマッチする正規表現
  IDENT_JOB       = %r|^//(#{CHARSET_NAME})\s+JOB\s+(\S+)\s*$|
  # EXEC文にマッチする正規表現
  IDENT_EXEC      = %r|^//(#{CHARSET_NAME})\s+EXEC\s+(\S+)\s*$|
  # DD名のあるDD文にマッチする正規表現
  IDENT_DD        = %r|^//(#{CHARSET_NAME})\s+DD\s+(\S+)\s*$|
  # DD名の無いDD文にマッチする正規表現
  IDENT_CONCAT    = %r|^//\s+DD\s+(\S+)\s*$|
  # 継続パラメータにマッチする正規表現
  IDENT_PARAM     = %r|^//\s+(\S+)\s*$|
  # コメント行にマッチする正規表現
  IDENT_COMMENT   = %r|^//\*|
  # 区切り行にマッチする正規表現
  IDENT_PERTITION = %r|^/\*|

  # JCLの書法に従ったスクリプトファイルをロードします。
  #
  # By default, +camelize+ converts strings to UpperCamelCase. If the argument to +camelize+
  # is set to <tt>:lower</tt> then +camelize+ produces lowerCamelCase.
  #
  # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
  #
  # Examples:
  #   "active_record".camelize                # => "ActiveRecord"
  #   "active_record".camelize(:lower)        # => "activeRecord"
  #   "active_record/errors".camelize         # => "ActiveRecord::Errors"
  #   "active_record/errors".camelize(:lower) # => "activeRecord::Errors"

  def self.load_file filename
    current_job =  current_step  = current_dd = nil

    File.open(filename)do |file|
      file.each do |line|
        line = (line.chomp)[0..71]

        case
        when line =~ IDENT_JOB
          current_job  = Job.new $1, $2
          current_step = nil
          current_dd   = nil
          current_data = nil

        when line =~ IDENT_EXEC
          current_step = Step.new $1, $2
          current_job.add_step(current_step)
          current_dd   = nil

        when line =~ IDENT_DD
          current_data = Dd.new $1, $2
          current_dd.add(current_data)
          if current_step
            current_step.add_dd(current_dd)
          else
            current_job.add_joblib(current_dd)
          end

        when line =~ IDENT_CONCAT
          if current_dd
            concat_data = Dd.new current_dd.name, $1
            current_dd.add(concat_data)
          end

        when line =~ IDENT_PARAM
          case
          when current_dd   then current_data.add_param $1
          when current_step then current_step.add_param $1
          when current_job  then current_job.add_param  $1
          end

        when line =~ IDENT_COMMENT

        when line =~ IDENT_PERTITION

        else
          if current_data
            current_dd.cardin += line
          end
        end
      end
    end
  end

  module JclStatement
    attr_accessor :name, :param
    attr_reader :command

    def initialize command, arg
      @command = command
      @name = arg.shift
      param = arg.shift
      @param = param ? param.parametize : {}
    end
    def add_param str
      @param = @param ? @param.update(str.parametize) : str.parametize
    end
    def to_jcl
      "//#{@name} #{@command} #{@param.to_a.sort{|a,b|(b[0]<=>a[0])}.
      map{|pair|"#{pair[0]}=#{pair[1]}"}.join(',')}"
    end
    def is_job?;  self.command == 'JOB'  end
    def is_step?; self.command == 'EXEC' end
    def is_dd?;   self.command == 'DD'   end
  end


  class Job; include JclStatement
    attr_accessor :libs,:steps
    def initialize *arg
      super 'JOB', arg
      @libs  = []
      @steps = []
    end
    def add_lib lib
      if lib.is_dd?
        @libs.push lib
      else
        rise "JOBLIB append error: #{lib.inspect} is not DD."
      end
    end
    def add_step step
      if step.is_step?
        @steps.push step
      else
        raise
      end
    end
  end



  class Step; include JclStatement
    attr_accessor :libs,:dds
    def initialize *arg
      super 'EXEC', arg
      @libs = []
      @dds = []
    end
    def add_lib lib
      if lib.is_dd?
        @libs.push lib
      else
        raise
      end
    end
    def add_dd  dd
      if dd.is_dd?
        @steps.push dd
      else
        raise
      end
    end
  end



  class Dd; include JclStatement
    attr_accessor :cardin
    def initialize *arg
      super 'DD', arg
    end
    def dsn; @param['DSN'] end
    def dsn= str; @param['DSN'] = str end
  end
end
