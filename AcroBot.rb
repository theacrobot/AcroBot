require 'rubygems'
require 'cinch'
require 'yaml'

DEFAULT_DICTIONARY = {
  'new' => { 'tbd' => 'To be done.' }
}

module AbbrevBot

  def initialize_dictionary
    File.open('abbrev.yaml', 'w') { |f|
      YAML.dump(DEFAULT_DICTIONARY, f)
    }
    dictionary
  end

  # Try to load the YAML file. If it does not exists initialize the
  # file and populate it with DEFAULT_DICTIONARY.
  # If the file exists but is scrumbled (false), do the same thing.
  #
  def dictionary
    begin
      YAML.load_file('abbrev.yaml') || initialize_dictionary
    rescue Errno::ENOENT
      initialize_dictionary
    end
  end

  # Open the YAML file with dictionary and look for the abbrev
  def lookup_dictionary(abbrev)
  	results = []
    dictionary.each do |key, values|
      # next if key == 'new' # Skip items in the 'new' group
      matched_keys = values.keys.select { |k| k.casecmp(abbrev) == 0 }
      matched_keys.each do |k|
      	results << [k, values[k]]
      end
    end
    results.empty? ? false : results 
  end

  def save_abbrev(name, description)
    dict = dictionary
    dict['new'] ||= {}
    dict['new'][name.strip] = description.strip
    File.open('abbrev.yaml', 'w') { |f| YAML.dump(dict, f) }
  end

end

include AbbrevBot

bot = Cinch::Bot.new do

  configure do |c|
   c.nick = "AcroBot"
   c.realname = "IRC Acronym and Abbreviation Expander Bot"
   c.user = "AcroBot" #user name when connecting
   c.server = "irc.freenode.org"
   c.channels =["#eli-test"]
   c.prefix = /^:/
  end

  on :message, /^:([\w\-\_]+)=(.+)/ do |m, abbrev, desc|
    save_abbrev(abbrev, desc)
    if m.channel?
      m.reply("#{m.user.nick}: Thanks! [#{abbrev}=#{desc}]")
    else
      m.reply("Thanks! [#{abbrev}=#{desc}]")
    end
  end

  on :message, /^:help/i do |m|
    if m.channel?
      m.reply("#{m.user.nick}: To expand an acronym, type e.g. *rhel")
      m.reply("#{m.user.nick}: To add a new acronym, type e.g. *RHEL=Red Hat Enterprise Linux")
    else # TODO: tyto retezce se opakuji, co by nemely
      m.reply("To expand an acronym, type e.g. *rhel")
      m.reply("To add a new acronym, type e.g. *rhel=Red Hat Enterprise Linux")
    end
  end
  
  on :message, /^:([\w\-\_]+)$/ do |m, abbrev|
  	abbrev = abbrev.strip
    unless abbrev =~ /^help$/i
      nick_str = m.channel? ? "#{m.user.nick}:" : ''
      if replies = lookup_dictionary(abbrev)
      	replies.each do |original_abbrev, value|
      		reply_str = "%s %s stands for %s" % [
          	nick_str,
          	Cinch::Formatting.format(:bold, original_abbrev),
          	Cinch::Formatting.format(:bold, value)
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
