require './shituf.rb'

s = Shituf.new('username@gmail.com','password')

while(1) do
	s.shareMail()
	puts "1"
	sleep(5)
end