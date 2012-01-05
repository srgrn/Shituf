# encoding: UTF-8
require 'rubygems'
gem 'ruby-gmail'

class Shituf
	def initialize(username,password)
	@username = username
	@password = password
	@registered =[]
	end
	attr_accessor :registered
	Commands = {
		"ADD ME" => ->(name){name.each do |n|; @registered << n if !@registered.include? n; end },
		"REMOVE ME" => ->(name){ name.each do |n|; @registered.delete n;end },
		"OTHER" => ->(n=0){puts "Do Nothing" }
	}
	def run_command(cmd,*param)
		instance_exec(param, &Commands[cmd]) if Commands.key?(cmd)
	end
	def loadRegistered(path)
		File.open(path).each_line{ |line|
		@registered << line
		}
		rescue
		
	end
	def saveRegistered(path)
		file = File.open(path,"w+")
		@registered.each do |address|
			file << address
		end
		file.close
	end
	def saveAttachments(attlist)
		attlist.each do |a|
			file = File.new(".\\attach\\" + a.filename, "w+")
			file << a.decoded
			file.close
		end
	end
	def foreward(msg)
		if msg.attachments 
			saveAttachments(msg.attachments)
			#msg.save_attachments_to('./attach/')
		end
		forwarded = msg.clone
		@registered.each do |addr|
			#forwarded = Mail.new do
			#	to addr
			#	subject msg.subject
			#	html_part do
			#		content_type 'text/html; charset=UTF-8'
			#		body msg.html_part.decoded
			#	end
			#	msg.attachments.each do |att|
			#		add_file (".\\attach\\"+att.filename)
			#	end
			#end
			forwarded.to = addr
			@gmail.deliver(forwarded)
		end
	end
	def action(msg)
		if Commands.key? msg.subject.upcase
			run_command(msg.subject.upcase,msg.from.first)
		else
			foreward(msg)
		end
	end

	def shareMail
		@gmail = Gmail.new(@username,@password)
		loadRegistered("list.txt")
		(@gmail.inbox.emails(:unread)).each do |msg|
			puts msg.subject
			action(msg)
		end
		saveRegistered("list.txt")
	end
end
