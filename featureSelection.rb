def selectFeatures(trainingDocs, trainingDocTerms, vocab, class_num, c)

print "\nFeature Selection for class " + c + "..."
termUtility = Hash.new

#for each term in vocabulary
vocab.each do |t|
	form = Hash.new
	
	x = 0.0
	countDocs = 0.0
	#for each document in class c, check if t exists
	trainingDocs[c].each do |dn|
		if trainingDocTerms[dn].include?(t)
			x += 1
		end
		countDocs += 1
	end
	form["on&present"] = x
	form["on&absent"] = countDocs - x
	on = countDocs

	y = 0.0
	countDocs = 0.0
	#for each document NOT in class c, check if t exists
	for i in 1..class_num
		cc = i.to_s
		if cc != c
			trainingDocs[cc].each do |dn|
				if trainingDocTerms[dn].include?(t)
					y += 1
				end
				countDocs += 1
			end
		end
	end
	form["off&present"] = y
	form["off&absent"] = countDocs - y
	off = countDocs

	#compute chi-squares
	n = 0.0
	form.each {|key, value|
		n += value
	}
	present = form["on&present"] + form["off&present"]
	absent = form["on&absent"] + form["off&absent"]
	
	eOnPresent = on * present / n
	eOnAbsent = on * absent / n
	eOffPresent = off * present / n
	eOffAbsent = off * absent / n

	chiSquare = (form["on&present"] - eOnPresent)**2 / eOnPresent + (form["on&absent"] - eOnAbsent)**2 / eOnAbsent + (form["off&present"] - eOffPresent)**2 / eOffPresent + (form["off&absent"] - eOffAbsent)**2 / eOffAbsent
	termUtility[t] = chiSquare
end


temp = termUtility.sort_by{|key, value| value}.reverse
j = c.to_i % 2
result = Array.new

for i in 0..(38 - j)
	result[i] = temp[i][0]
end

return result

end