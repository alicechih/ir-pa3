def extract(input_file)

#require gem for Porter's stemming
require 'stemmify'

#read input and downcase everything
text = input_file.downcase
#split input into array of strings & remove duplicates
words = text.tr(",","").tr("[.?\"]", " ").split(/\W+/)
#read stopwords into array of strings
stopwords = open('stopwords.txt', 'rb').read.split

extracted_file = Array.new

words.each do |a|
	if !stopwords.include?(a)
		#Porter's stemming EX.nbc's->nbc'
		b = a.stem
		#remove ' from stemmed words that end with ' EX.nbc'->nbc
		if b.match /\'$/
			b = b.chop
		end
		#remove abbrievations and recheck stopword list EX.don't
		if !b.include?("\'") && !stopwords.include?(b)
			extracted_file << b
		end
	end
end

#File.open('extracted_file.txt', 'wb') do |f|
#	f.write extracted_file
#	puts "extracted_file.txt created."
#end

return extracted_file
end