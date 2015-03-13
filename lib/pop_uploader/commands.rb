ARGV << '--help' if ARGV.empty?

command = ARGV.shift

require 'pop_uploader/commands_tasks'

PopUploader::CommandsTasks.new(ARGV).run_command!(command)
