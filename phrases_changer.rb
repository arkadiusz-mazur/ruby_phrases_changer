# *** Phrases Changer ***
#
# The most comfortable CONSOLE FEATURE written in Ruby to change phrases in directory recursively,
# in the safely way, without mistakes, with log what have been changed.
#
# This console feature in comparison to phrase changes options in many IDE ensure, you don`t be afraid
# that something will be changed even if you don`t wish unwanted changes in some places.

# Fill the documentation section below.
# To run the script just use command as below in console in the same directory as this script:
#
# $ ruby phrases_changer.rb

#***** CONFIGURATION - the only section you have to change for your own using the script **************
#
#
PATH_TO_DIRECTORY = 'example_files' # <-- YOUR CONF Path to directory with files to reworks
WHAT_I_WANT_TO_CHANGE = 'commodore64' # <-- YOUR CONF This is what you are changing
WHAT_I_WANT_TO_RETRIEVE = 'Amiga CD 32' # <-- YOUR CONF This is result phrase that you want to retrive.
#
#
#***** end of CONFIGURATION *** Thats all what you have to specify *************************************



$conf = {
  argv0: WHAT_I_WANT_TO_CHANGE,
  argv1: WHAT_I_WANT_TO_RETRIEVE,
  dir_path: File.join(Dir.pwd, PATH_TO_DIRECTORY),
  log_path: File.join(Dir.pwd, 'logs'),
}

# === This class manage of process: searches and iterate files, save changes to logs.
# Regarding to the logic of making changes in files is reposnible class ChangeFile located in the same file.
class PhrasesChanger

  DIRECTORY_PATH = $conf[:dir_path]
  LOG_PATH = $conf[:log_path]

  def initialize phrase_we_have_now, phrase_we_want_to_have
    @phrase_we_have_now = phrase_we_have_now
    @phrase_we_want_to_have = phrase_we_want_to_have
    main
  end

  # @return
  # void
  def main
    files_list = search_in_project @phrase_we_have_now
    objChangeFile = ChangeFile.new @phrase_we_have_now
    files_list.each do |file_path|
      file_before = file_content file_path
      log_hash = { file_path: file_path, phrase_we_have_now: @phrase_we_have_now }
      several_file_phrases = objChangeFile.iterate_several_file file_path
      several_file_phrases.each do |line_to_change|
        let_me_change = objChangeFile.ask_for_several_change_in_file line_to_change, file_path
        if let_me_change
          make_check = objChangeFile.make line_to_change, @phrase_we_have_now, @phrase_we_want_to_have, file_path
          raise "The problem with 'make' function occurs!" unless make_check
          puts "\n\e[39mThe phrase \e[31m'#{@phrase_we_have_now}' \e[39mis currently changed to \e[32m'#{@phrase_we_want_to_have}'\e[34m in file:\e[30m"
          puts "#{file_path}\n\n"
        else
          puts "No file has been changed\n\n"
        end
      end
      #If you will not stop the script and finish the changes, you will have log with all changes.
      #Otherwise log file will not created.
      puts "\e[39m*                                        *"
      puts '*            Process complete            *'
      puts '*    You can see changes in log file     *'
      puts "******************************************\n"
      puts "Log file path: #{File.join(LOG_PATH, adjust_log_name(@phrase_we_have_now))}\n\n\n\n\n\n\n"
      file_after = file_content file_path
      append_to_log log_hash, file_before, file_after
    end
  end

  # === Return files where occurs: phrase_we_have_now
  # @return Array
  def search_in_project phrase_we_have_now
    result_files_with_phrase = []
    path_to_files = File.join(DIRECTORY_PATH, '**/*.rb')
    files_to_check = []
    Dir.glob(path_to_files) do |rb_file|
      files_to_check << rb_file
    end
    raise "files_to_check is empty !" if files_to_check.length == 0
    #Looking for files where occurs: phrase_we_have_now
    files_to_check.each do |one_file|
      file = File.open(one_file, "r") do |f|
        f.each_line do |line|
          reg = /.*#{@phrase_we_have_now}.*/
          if line.match?(reg)
            result_files_with_phrase << one_file
          end
        end
      end
    end
    if result_files_with_phrase.length == 0
      puts "\n\e[31m\e[1;4mThe phrase: '#{@phrase_we_have_now}' not found in files.\e[31m"
      exit
    end
    result_files_with_phrase.uniq.sort
  end

  # @return
  # void
  def append_to_log log_hash, file_before, file_after
    raise "log_hash is not a Hash!" unless log_hash.is_a?(Hash)
    data = "\n\n+++++++++++++++++++++++++++++++++ #{Time.now.to_s} ++++++++++++++++++++++++++++++++++\n"
    data += "#{log_hash[:file_path]}\n"
    data += "BEFORE: \n" + file_before + "\n----------------------------------------------\nAFTER:\n" + file_after
    File.open(File.join(LOG_PATH, adjust_log_name(log_hash[:phrase_we_have_now])), "a") do |f|
      f.write(data)
    end
  end

  # @return String
  def file_content file_path
    data = File.read(file_path)
  end

  private

  # @return String
  def adjust_log_name name
    change = name.strip.gsub!(':', '_')
    return change if change
    return name
  end
end


# === Class responsible of the logic of making changes process.
class ChangeFile

  def initialize phrase_we_have_now
    @phrase_we_have_now = phrase_we_have_now
    @change_all = false
  end

  # === Return array which contains lines with searched phrase for indicated file.
  # @return Array
  def iterate_several_file file_path
    #Iterate file line by line
    result_lines_in_file = []
    reg = /.*#{@phrase_we_have_now}.*/
    file = File.open(file_path, "r") do |f|
      f.each_line do |line|
        if line.match?(reg)
          result_lines_in_file << line
        end
      end
    end
    result_lines_in_file
  end

  # This method ask you for confirmation if you want to make indicated change.
  # @return Boolean
  def ask_for_several_change_in_file line_to_change, file_path
    if @change_all
      puts "\n\e[39m******************************************"
      puts '*                                        *'
      puts '* Automatically changes has been started *'
      puts '*                                        *'
      puts "\nFile: #{file_path}\n\n"
      return true
    end
    puts "\n\e[39m******************************************"
    puts '*                                        *'
    puts '* Follow the instructions below to       *'
    puts '* make changes in file                   *'
    puts "\nPhrase:\n #{line_to_change}\nfound in file:\n#{file_path}\n"
    print "\e[31m\e[1;4m\nDo I have to change this phrase [y/n/all] (default \e[32m\e[1;4mYes\e[31m) ?\n"
    choise = STDIN.gets.chomp.upcase
    res = false
    if choise == 'Y' || choise.length == 0
      res = true
    elsif choise == 'A'
      res = true
      @change_all = true
    end
    res
  end

  # Returns bool value for info if changes made correctly or rather problem occurs.
  # @return Boolean
  def make line_to_change, phrase_we_have_now, phrase_we_want_to_have, file_path
    verbose = $conf[:verbose]
    if verbose
      puts "\e[39m-----------------------------"
      puts "I'm changing:\n#{phrase_we_have_now}"
      puts '-----------------------------'
      puts "to:\n#{phrase_we_want_to_have}"
      puts '-----------------------------'
    end

    #Change every occurence
    puts "in file:\n#{file_path}" if verbose
    data = File.read(file_path)
    puts "\n\e[31m++Old version: \e[30m\n" if verbose
    puts data + "\n" if verbose

    line_changed = line_to_change.gsub(phrase_we_have_now, phrase_we_want_to_have)
    data.sub! line_to_change, line_changed

    puts "\n\e[32m++New version: \e[30m\n" if verbose
    puts data + "\n" if verbose
    puts "\e[31mOld line:\n #{line_to_change}\e[32m\nNew line:\n#{line_changed}\e[30m" #Standard info. verbose = true -> shows all file
    #Write the file
    res = false
    res = File.open(file_path, "w") do |f|
      f.write(data)
    end
    if res
      return true
    end
    false
  end
end

PhrasesChanger.new $conf[:argv0], $conf[:argv1]

# Ruby 2.5.1
# 2018, Arkadiusz Mazur, gmail address: programmer.rails
