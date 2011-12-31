# encoding: UTF-8

require 'gmail'

@username = 'example@gmail.com'
@password = 'secret'
@registered =[]

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
	@registered.each do |addr|
		forwarded = Mail.new do
			to addr
			subject msg.subject
			html_part do
				content_type 'text/html; charset=UTF-8'
				body msg.html_part.decoded
			end
			msg.attachments.each do |att|
				add_file (".\\attach\\"+att.filename)
			end
		end
		@gmail.deliver(forwarded)
	end
end
def action(msg)
	if msg.subject.upcase == "ADD ME"
		@registered << msg.from.first unless @registered.include? msg.from.first
	elsif msg.subject.upcase == "REMOVE ME"
		@registered.delete(msg.from.first)
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


shareMail()