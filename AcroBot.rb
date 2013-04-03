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
    dictionary.each do |key, values|
      # next if key == 'new' # Skip items in the 'new' group
      if value = values[abbrev.strip.downcase]
        return value
      end
    end
    false
  end

  def save_abbrev(name, description)
    dict = dictionary
    dict['new'] ||= {}
    dict['new'][name.strip.downcase] = description.strip
    File.open('abbrev.yaml', 'w') { |f| YAML.dump(dict, f) }
  end

end

include AbbrevBot

bot = Cinch::Bot.new do

  configure do |c|
   c.nick = "AcroBot"
   c.realname = "Abbreviations expander"
   c.user = "AcroBot" #user name when connecting
   c.server = "irc.freenode.org"
   c.channels =["#eli-test"]
   c.prefix = /^\*/
  end

  on :message, /^\*(\w+)=(.+)/ do |m, abbrev, desc|
    save_abbrev(abbrev, desc)
    if m.channel?
      m.reply("#{m.user.nick}: Thanks! [#{abbrev.downcase}=#{desc}]")
    else
      m.reply("Thanks! [#{abbrev.downcase}=#{desc}]")
    end
  end

  on :message, /^\*help/ do |m|
    if m.channel?
      m.reply("#{m.user.nick}: To view an abbreviation, type eg. *rhel")
      m.reply("#{m.user.nick}: To add a new abbreviation, type eg. *rhel=Red Hat Enterprise Linux (RHEL)")
    else
      m.reply("To view an abbreviation, type eg. *rhel")
      m.reply("To add a new abbreviation, type eg. *rhel=Red Hat Enterprise Linux (RHEL)")
    end
  end

  on :message, /^\*(\w+)$/ do |m, abbrev|
    return if abbrev.strip == 'help'
    nick_str = m.channel? ? "#{m.user.nick}:" : ''
    if !abbrev.nil? and reply=lookup_dictionary(abbrev)
      reply_str = "%s '%s' stands for '%s'" % [
        nick_str,
        Cinch::Formatting.format(:bold, abbrev.strip.upcase),
        Cinch::Formatting.format(:bold, reply)
      ]
      m.reply(reply_str.strip)
    else
      m.reply("#{nick_str} Sorry, no definition for #{abbrev.strip}")
    end
  end

end

bot.start
