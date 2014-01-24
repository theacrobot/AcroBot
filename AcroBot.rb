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
#   c.server = "irc.freenode.org"
#   c.channels =["#testing_acrobot"]
   c.server = "irc.bne.redhat.com"
   c.channels =["#wordnerds","#cloud-docs","#ecsbrno"]
   c.prefix = /^!/
  end

  on :message, /^!([\w\-\_]+)\=(.+)/ do |m, abbrev, desc|
  	nick = m.channel? ? m.user.nick+": " : ""
  	save_abbrev(abbrev, desc)
   nick = m.channel? ? m.user.nick+": " : ""
    m.reply("#{nick}Thanks! [#{abbrev}=#{desc}]") 
  end

  on :message, /^!help/i do |m|
    nick = m.channel? ? m.user.nick+": " : ""
    m.reply("#{nick}To expand an acronym, type (e.g.), !rhel")
    m.reply("#{nick}To add a new acronym, type (e.g.), !RHEL=Red Hat Enterprise Linux")
    m.reply("#{nick}To associate a tag with an acronym, type (e.g.), !CFME=CloudForms Management Engine @cloud")
    m.reply("#{nick}To list abbrevs associated with a tag, type eg. !@kernel")
    m.reply("#{nick}To list all tags, type !@tags")
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
