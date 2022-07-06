%w{rubygems pp irb/ext/save-history ap }.each do |lib|
  begin
    require lib
  rescue LoadError => err
    $stderr.puts "Couldn't load #{lib}: #{err}"
  end
end

IRB_START_TIME = Time.now

# Prompt behavior
ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

#########################
ANSI_BOLD       = "\033[1m"
ANSI_RESET      = "\033[0m"
ANSI_LGRAY    = "\033[0;37m"
ANSI_GRAY     = "\033[1;30m"
ANSI_BLUE     = "\033[1;33m"
ANSI_RED     = "\033[1;32m"

class Object
  def pm(*options) # Print methods
    methods = self.methods
    methods -= Object.methods unless options.include? :more
    filter = options.select {|opt| opt.kind_of? Regexp}.first
    methods = methods.select {|name| name =~ filter} if filter

    data = methods.sort.collect do |name|
      method = self.method(name)
      if method.arity == 0
        args = "()"
      elsif method.arity > 0
        n = method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")})"
      elsif method.arity < 0
        n = -method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")}, ...)"
      end
      klass = $1 if method.inspect =~ /Method: (.*?)#/
      [name, args, klass]
    end
    max_name = data.collect {|item| item[0].size}.max
    max_args = data.collect {|item| item[1].size}.max
    data.each do |item|
      print "#{ANSI_LGRAY}#{item[0].rjust(max_name)}#{ANSI_RESET}"
      print "#{ANSI_BLUE}#{item[1].ljust(max_args)}#{ANSI_RESET}"
      print "#{ANSI_RED}#{item[2]}#{ANSI_RESET}\n"
    end
    data.size
  end
end
#########################

#history
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT_MODE] = :SIMPLE

# Loaded when we fire up the Rails console
# among other things I put the current environment in the prompt

if ENV['RAILS_ENV']
  rails_env = ENV['RAILS_ENV']
  rails_root = File.basename(Dir.pwd)
  prompt = "#{rails_root}[#{rails_env.sub('production', 'prod').sub('development', 'dev')}]"
  IRB.conf[:PROMPT] ||= {}

  IRB.conf[:PROMPT][:RAILS] = {
    :PROMPT_I => "#{prompt}>> ",
    :PROMPT_S => "#{prompt}* ",
    :PROMPT_C => "#{prompt}? ",
    :RETURN   => "=> %s\n"
  }

  IRB.conf[:PROMPT_MODE] = :RAILS

  #Redirect log to STDOUT, which means the console itself
  IRB.conf[:IRB_RC] = Proc.new do
    logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger = logger
    ActiveRecord::Base.instance_eval { alias :[] :find }
  end

  ### RAILS SPECIFIC HELPER METHODS
  # TODO: DRY this out
  def log_ar_to (stream)
    ActiveRecord::Base.logger = expand_logger stream
    reload!
  end

  def log_ac_to (stream)
    logger = expand_logger stream
    ActionController::Base.logger = expand_logger stream
    reload!
  end

  def expand_log_file(name)
    "log/#{name.to_s}.log"
  end

  def expand_logger(name)
    if name.is_a? Symbol
      logger = expand_log_file name
    else
      logger = name
    end
    Logger.new logger
  end
end

### IRb HELPER METHODS

#clear the screen
def clear
  system('clear')
end
alias :cl :clear

#ruby documentation right on the console
# ie. ri Array#each
def ri(*names)
  system(%{ri #{names.map {|name| name.to_s}.join(" ")}})
end

### CORE EXTENSIONS
class Object
  #methods defined in the parent class of the object
  def local_methods
    (methods - Object.instance_methods).sort
  end

  #copy to pasteboard
  #pboard = general | ruler | find | font
  def to_pboard(pboard=:general)
    %x[printf %s "#{self.to_s}" | pbcopy -pboard #{pboard.to_s}]
    paste pboard
  end
  alias :to_pb :to_pboard

  #paste from given pasteboard
  #pboard = general | ruler | find | font
  def paste(pboard=:general)
    %x[pbpaste -pboard #{pboard.to_s}].chomp
  end

  def to_find
    self.to_pb :find
  end

  def eigenclass
    class << self; self; end
  end

  def ql
    %x[qlmanage -p #{self.to_s} >& /dev/null  ]
  end
end

class Class
  public :include

  def class_methods
    (methods - Class.instance_methods - Object.methods).sort
  end

  #Returns an array of methods defined in the class, class methods and instance methods
  def defined_methods
    methods = {}

    methods[:instance] = new.local_methods
    methods[:class] = class_methods

    methods
  end

  def metaclass
    eigenclass
  end
end

### USEFUL ALIASES
alias q exit
require 'irb/completion'
require 'rubygems'

puts "environment: #{Rails.env}"

ActiveRecord::Base.logger.level = 1 if defined?(ActiveRecord)
IRB.conf[:SAVE_HISTORY] = 1000

# Overriding Object class
class Object
  # Easily print methods local to an object's class
  def lm
    (methods - Object.instance_methods).sort
  end

  # look up source location of a method
  def sl(method_name)
    self.method(method_name).source_location rescue "#{method_name} not found"
  end

  # open particular method in vs code
  def ocode(method_name)
    file, line = self.sl(method_name)
    if file && line
      `code -g '#{file}:#{line}'`
    else
      "'#{method_name}' not found :(Try #{self.name}.lm to see available methods"
    end
  end

  # display method source in rails console
  def ds(method_name)
    self.method(method_name).source.display
  end

  # open json object in VS Code Editor
  def oo
    tempfile = File.join(Rails.root.join('tmp'), SecureRandom.hex)
    File.open(tempfile,'w') {|f| f << self.as_json}
    system("#{'code'||'nano'} #{tempfile}")
    sleep(1)
    File.delete( tempfile )
  end
end

# history command
def hist(count = 0)
  # Get history into an array
  history_array = Readline::HISTORY.to_a

  # if count is > 0 we'll use it.
  # otherwise set it to 0
  count = count > 0 ? count : 0

  if count > 0
    from = history_array.length - count
    history_array = history_array[from..-1]
  end

  print history_array.join("\n")
end

# copy a string to the clipboard
def cp(string)
  `echo "#{string}" | pbcopy`
  puts "copied in clipboard"
end

# reloads the irb console can be useful for debugging .irbrc
def reload_irb
  load File.expand_path("~/.irbrc")
  # will reload rails env if you are running ./script/console
  reload! if @script_console_running
  puts "Console Reloaded!"
end

# opens irbrc in vscode
def edit_irb
  `code ~/.irbrc` if system("code")
end

def bm
  # From http://blog.evanweaver.com/articles/2006/12/13/benchmark/
  # Call benchmark { } with any block and you get the wallclock runtime
  # as well as a percent change + or - from the last run
  cur = Time.now
  result = yield
  print "#{cur = Time.now - cur} seconds"
  puts " (#{(cur / $last_benchmark * 100).to_i - 100}% change)" rescue puts ""
  $last_benchmark = cur
  result
end

# exit using `q`

alias q exit

# all available methods explaination
def ll
  puts '============================================================================================================='
  puts 'Welcome to rails console. Here are few list of pre-defined methods you can use.'
  puts '============================================================================================================='
  puts 'obj.sl(:method) ------> source location e.g lead.sl(:name)'
  puts 'obj.ocode(:method) ---> open method in vs code e.g lead.ocode(:name)'
  puts 'obj.dispsoc(:method) -> display method source in rails console e.g lead.dispsoc(:name)'
  puts 'obj.oo ---------------> open object json in vs code e.g lead.oo'
  puts 'hist(n) --------------> command history e.g hist(10)'
  puts 'cp(str) --------------> copy string in clipboard e.g cp(lead.name)'
  puts 'bm(block) ------------> benchmarking for block passed as an argument e.g bm { Lead.all.pluck(:stage);0 }'
  puts '============================================================================================================='
end

def admin(email)
  User.find_by email: email
end
