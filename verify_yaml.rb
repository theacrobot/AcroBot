#!/usr/bin/env ruby

require 'find'
require 'yaml'

# Find all YAML files in the current folder recursively
#
# Returns:
# - list<str> of files
def get_yaml_files

  yaml_files = []

  Find.find('.') { |e| yaml_files << e if e.end_with?('.yaml', '.yml')}

  yaml_files
end

# Verify if YAML file has valid syntax or not
#
# Parameters:
# - <str: yaml file>
#
# Returns:
# - List [<bool: is it valid>, <str: error message>]
#
#   error message is 'nil' if no errors
def is_yaml_file_valid?(yaml_file)

  begin
    YAML.load_file(yaml_file)
    [true, nil]
  rescue => error
    [false, error.message]
  end
end

any_errors = false

get_yaml_files.each do |yaml_file|

  yaml_valid, error_message = is_yaml_file_valid?(yaml_file)

  if yaml_valid
    puts "YAML file '#{yaml_file}' valid!"
  else
    any_errors = true
    puts ">> YAML file '#{yaml_file}' is not valid!"
    puts ">> Error: #{error_message}"
  end
end

# Exit with non-zero exit status if any errors
exit(false) if any_errors
