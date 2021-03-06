#!/usr/bin/env ruby
require 'mechanize'
require 'yaml'
require 'fileutils'

class Instapaper
  class ConfigFile

    def initialize(config_file = "~/.instapaper_download")
      @config_file = File.expand_path(config_file)
      @config_hash = {}
      @save_to_file = nil
    end

    def read_from_file
      raise "Please make sure that #{@config_file} exists" unless exists?
      @config_hash = YAML::load_file(@config_file)
    end

    def create_or_update
      File.open(@config_file, "w") do |file|
        file.write(YAML::dump(@config_hash))
      end
      puts %Q{Saved configuration to "#{@config_file}"}
    end

    def exists?
      File.exists?(@config_file) && File.file?(@config_file)      
    end

    def path
      @config_file
    end

    def save_to_file_if_necessary(hash)
      @config_hash = @config_hash.merge(hash) #Overwrites old values from @config_hash with new values from hash in case of identical keys
      puts
      while @save_to_file.nil? do
        print "Should I hold on to this information for you? Caution: The password is stored in plain text! [y/n] "
        response = gets.chomp.downcase
        if response == "y"
          @save_to_file = true
        elsif response == "n"
          @save_to_file = false
        end
      end
      if @save_to_file
        create_or_update
      end
    end
  end

  class Account
    attr_reader :email, :password
    def initialize(email, password)
      @email = email
      @password = password
    end
    def self.from_config_file(config_file = ConfigFile.new)
      config = {}
      config = config_file.read_from_file if config_file.exists?
      unless config[:email] and config[:password]
        print "Please enter instapaper email address: "
        email = gets.chomp
        print "Please enter instapaper password: "
        `stty -echo`
        password = gets.chomp
        `stty echo`
        config[:email] = email
        config[:password] = password
        config_file.save_to_file_if_necessary(config)
      end
      return Account.new(config[:email], config[:password])
    end
  end

  class LoginPage
    def initialize(agent)
      @agent = agent
      @url = "http://www.instapaper.com/user/login"
      @logged_in = false
    end
    def login(account)
      puts "Logging in as #{account.email}"
      page = @agent.get(@url)
      login_form = page.forms.first
      login_form.field_with(:name => "username").value = account.email
      login_form.field_with(:name => "password").value = account.password
      page = @agent.submit(login_form)
      @logged_in = true  if page.title == "Logging in..."
      @agent
    end
    def logged_in?
      @logged_in
    end
  end

  class EpubDownloadPage
    def initialize(agent)
      @agent = agent
      @url = "http://www.instapaper.com/epub"
    end
    def download
      page = @agent.get(@url)
    end
  end

end

class EbookReader
  attr_reader :mount_point

  def initialize(path)
    @mount_point = path
  end

  def self.from_config_file(config_file = ConfigFile.new)
    config = {}
    config = config_file.read_from_file if config_file.exists?
    unless config[:ebook_reader_path]
      print "Where is your ebook reader mounted?: "
      path = gets.chomp
      config[:ebook_reader_path] = path
      config_file.save_to_file_if_necessary(config) 
    end
    return EbookReader.new(config[:ebook_reader_path])
  end

  def is_mounted?
    File.exists?(@mount_point) and File.directory?(@mount_point)
  end

  def move_to_device(file)
    raise %Q{The ebook reader does not seem to be mounted on "#{@mount_point}"} unless is_mounted?
    file = File.expand_path(file)
    @mount_point = File.expand_path(@mount_point)
    FileUtils.mv(file, @mount_point)
    puts %Q{Moved "#{file}" to your ebook reader}
  end

end


#TODO: Deploy it like: https://github.com/defunkt/cheat
