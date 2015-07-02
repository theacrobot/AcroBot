require 'rubygems'
require 'cinch'
require 'yaml'

DEFAULT_DICTIONARY = {
  'new' => { 'tbd' => 'To be done.' }
}

module AbbrevBot

  @@home_dir = File.expand_path '~/.config'
  @@install_dir = File.expand_path File.dirname(__FILE__)
  #@@abbrevs_file = "#{@@install_dir}/abbrev.yaml"
  @@cfg_file = 'acrobot.yaml'

# this bit won't work yet because we're not using @@abbrevs_file
#  def initialize_dictionary
#    File.open(@@abbrevs_file, 'w') { |f|
#      YAML.dump(DEFAULT_DICTIONARY, f)
#    }
#    dictionary
#  end
  def initialize_dictionary(name)
    File.open(name, 'w') { |f|
      YAML.dump(DEFAULT_DICTIONARY, f)
    }
    #dictionary
  end

  # Try to load the YAML file. If it does not exist initialize the
  # file and populate it with DEFAULT_DICTIONARY.
  # If the file exists but is scrumbled (false), do the same thing.
  #
  def dictionary
      begin
      h1 = YAML.load_file('public.yaml')
      if h1 == false
          puts("Initializing dictionary...")
          initialize_dictionary('public.yaml')
      h1 = YAML.load_file('public.yaml')
      end
      h2 = YAML.load_file('draft.yaml')
      if h2 == false
          puts("Initializaing dictionary...")
          initialize_dictionary('draft.yaml')
      h2 = YAML.load_file('draft.yaml')
      end
      h3 = YAML.load_file('slang.yaml')
      if h3 == false
          puts("Initializing dictionary...")
          initialize_dictionary('slang.yaml')
      h3 = YAML.load_file('slang.yaml')
      end
      h4 = YAML.load_file('internal.yaml')
      if h4 == false
          puts("Initializing dictionary...")
          initialize_dictionary('internal.yaml')
      h4 = YAML.load_file('internal.yaml')
      end
      h5 = YAML.load_file('tags.yaml')
      if h5 == false
          puts("Initializing dictionary...")
          initialize_dictionary('tags.yaml')
      h5 = YAML.load_file('tags.yaml')
      end
      # all tables should be merged
      h1.merge(h2).merge(h3).merge(h4).merge(h5)
      rescue Errno::ENOENT
      initialize_dictionary('public.yaml')
      initialize_dictionary('draft.yaml')
      initialize_dictionary('slang.yaml')
      initialize_dictionary('internal.yaml')
      initialize_dictionary('tags.yaml')
      h1 = YAML.load_file('public.yaml')
      h2 = YAML.load_file('draft.yaml')
      h3 = YAML.load_file('slang.yaml')
      h4 = YAML.load_file('internal.yaml')
      h5 = YAML.load_file('tags.yaml')
      # all tables should be merged
      h1.merge(h2).merge(h3).merge(h4).merge(h5)
    end

#    begin
#      YAML.load_file(@@abbrevs_file) || initialize_dictionary
#    rescue Errno::ENOENT
#      initialize_dictionary
#    end
  end

  # Open the YAML file with dictionary and look for the abbrev
  def lookup_dictionary(abbrev)
    results = []
    dictionary.each do |key, values|
      next if values.nil?
      # next if key == 'new' # Skip items in the 'new' group
      matched_keys = values.keys.select { |k| k.to_s.casecmp(abbrev) == 0 }
      # => ['tbd', 'rhel'] ...
      matched_keys.each do |k|
        results << [k, values[k]]
      end
    end
    results.empty? ? false : results
  end

  #Find abbrevs with a certain tag
  def find_values(tag)
    results =[]
    dictionary.each do |key, values|
      next if values.nil?
      matched_keys = values.select { |k,v| v.to_s =~ /@#{tag}( |$)/i }.keys.each do |k|
        results << k
      end
    end
    results
  end

  def save_abbrev(name, description)
    dict = dictionary
    dict['new'] ||= {}
    dict['new'][name.strip] = description.strip + ' @unchecked'
    File.open('draft.yaml', 'w') { |f| YAML.dump(dict, f) }
  end

  def load_settings
    require 'yaml'
    return YAML::load_file("#{@@home_dir}/#{@@cfg_file}") if File.exists? "#{@@home_dir}/#{@@cfg_file}"
    return YAML::load_file("#{@@install_dir}/#{@@cfg_file}")
  end

end

include AbbrevBot

bot = Cinch::Bot.new do

  settings = load_settings

  configure do |c|
   c.nick = settings['nick']         # "Dacronym"
   c.realname = settings['realname'] # "IRC Acronym and Abbreviation Expander Bot. !help for help"
   c.user = settings['user']         # "Dacronym" #user name when connecting
   c.server = settings['server']     #"irc.freenode.net"
#   c.channels = settings['channels'] # ["#Dacronym","#katello","#openshift","#satellite6","#zanata","#theforeman"]
   c.channels = ["#Dacronym"]
   c.prefix = settings['prefix']     # /^!/
  end

  on :message, /^!([\w\-\_]+)\=(.+)/ do |m, abbrev, desc|
    nick = m.channel? ? m.user.nick+": " : ""
    save_abbrev(abbrev, desc)
   nick = m.channel? ? m.user.nick+"":""
    m.reply("#{nick} Thanks! [#{abbrev}=#{desc}]")
    m.reply("#{nick}++")
  end

  on :message, /^!help/i do |m|
    nick = m.channel? ? m.user.nick+": " : ""
    m.reply("To expand an acronym, type (e.g.), !ftp")
    m.reply("To add a new acronym, type (e.g.), !FTP=File Transfer Protocol")
    m.reply("To associate a tag with an acronym, type (e.g.), !IP=Internet Protocol @networking")
    m.reply("To list abbrevs associated with a tag, type eg. !@kernel")
    m.reply("To list all tags, type !@tags")
  end

  on :message, /^!@([\w\-\_]+)$/ do |m, tag|
    tag = tag.strip
    match_abbrevs = find_values(tag)
    nick = m.channel? ? m.user.nick+": " : ""
    if match_abbrevs.empty?
      m.reply("#{nick}Sorry, no such tag. To list all tags, type !@tags")
    else
        m.reply("#{nick}#{match_abbrevs.join(', ')}")
    end
  end

  on :message, /^!([\w\-\_]+)$/ do |m, abbrev|
    abbrev = abbrev.strip
    unless abbrev =~ /^help$/i
      nick_str = m.channel? ? "#{m.user.nick}:" : ""
      if replies = lookup_dictionary(abbrev)
        replies.each do |original_abbrev, value|
          value, *tags = value.split('@')
          reply_str = "%s %s stands for %s %s" % [
            nick_str,
            Cinch::Formatting.format(:bold, original_abbrev.to_s),
            Cinch::Formatting.format(:bold, value.strip),
            tags.map { |t| "@#{t.strip}" }.join(', ')
          ]
          m.reply(reply_str.strip)
        end
      else
        m.reply("#{nick_str} Sorry, no definition for #{abbrev}")
      end
    end
  end

end

bot.start
