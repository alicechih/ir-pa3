require_relative 'extraction'
require_relative 'featureSelection'

INPUT_DIR = 'IRTM_news_files'
CLASS_NUM = 13

# Read "training.txt" into trainingFiles{}

array = open('training.txt', 'rb').readlines
trainingFiles = Hash.new
array.each do |arr|
	a = arr.split
	trainingFiles[a[0]] = a.drop(1)
end

# Extract vocabulary from training document set (require extraction.rb)

print "Extracting vocabulary from training documents..."
vocab = Array.new
trainingFileTerms = Hash.new
trainingFiles.each { |key, docNames|
	docNames.each do |dn|
		f = open( INPUT_DIR + '/' + dn + '.txt', 'rb').read
		extracted_array = extract(f)
		trainingFileTerms[dn] = extracted_array
		vocab.concat(extracted_array)
	end
}
vocab = vocab.uniq

# Feature selection: chi-square (require featureSelection.rb)

vocabFS = Array.new
for i in 1..CLASS_NUM
	res = selectFeatures(trainingFiles, trainingFileTerms, vocab, CLASS_NUM, i.to_s)
	vocabFS.concat(res)
end

# Train multinomial Naive Bayes

print "\nTraining multinomial Naive Bayes..."

nTotal = 0.0
nClass = Array.new
prior = Array.new
condprob = Hash.new

for i in 1..CLASS_NUM
	nClass[i] = trainingFiles[i.to_s].count
	nTotal += nClass[i]
end

for i in 1..CLASS_NUM
	print "\nOn class " + i.to_s + "..."
	prior[i] = nClass[i] / nTotal
	
	#concatenate all docs from class c
	text = Array.new
	trainingFiles[i.to_s].each do |dn|
		text.concat(trainingFileTerms[dn])
	end

	termCount = Hash.new
	termCountTotal = 0.0

	vocabFS.each do |t|
		termCount[t] = text.count(t).to_f
		termCountTotal = termCountTotal + termCount[t] + 1
	end

	vocabFS.each do |t|
		if condprob.has_key?(t) == false
			a = Array.new
			condprob[t] = a
		end
		condprob[t][i] = (termCount[t] + 1) / termCountTotal
	end
end

# Apply multinomial Naive Bayes (require extraction.rb)

print "\nApplying multinomial Naive Bayes to testing documents..."
classifyResult = Hash.new

#put all training doc names in one array
trainingDocs = Array.new
for i in 1..CLASS_NUM
	trainingDocs.concat(trainingFiles[i.to_s])
end

#for each document
Dir.foreach( INPUT_DIR + '/') do |doc|
	next if doc == '.' or doc == '..'
	#if the document is not a training document
	if trainingDocs.include?(doc.chomp(".txt")) == false
		print "\nOn document " + doc + "..."

		f = open( INPUT_DIR + '/' + doc, 'rb').read
		terms = extract(f)
		score = Hash.new

		#compute score for each class
		for i in 1..CLASS_NUM
			score[i.to_s] = Math.log(prior[i])
			terms.each do |t|
				if vocabFS.include?(t)
					score[i.to_s] += Math.log(condprob[t][i])
				end
			end
		end

		scoreSorted = score.sort_by{|key, value| value}.reverse
		classifyResult[doc.chomp(".txt")] = scoreSorted[0][0]
	end
end

output = classifyResult.sort_by{|key, value| key.to_i}

File.open('output.txt', 'w') do |f|
	f.print "doc_id\tclass_id\n"
	output.each do |a|
		f.print a[0].to_s + "\t" + a[1].to_s + "\n"
	end
	puts "\n\n\"output.txt\" created."
end