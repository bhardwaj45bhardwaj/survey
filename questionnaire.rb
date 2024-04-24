require "pstore" # https://github.com/ruby/pstore
require 'rspec'

STORE_NAME = "tendable.pstore"
$store = PStore.new(STORE_NAME)

QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

QUESTIONS_COUNT = QUESTIONS.count



# TODO: FULLY IMPLEMENT
def do_prompt
  true_count ||= 0 
  # Ask each question and get an answer from the user's input.
  QUESTIONS.each_key do |question_key|
    print QUESTIONS[question_key]
    ans = gets.chomp
    ans = ans.downcase
    if ["yes", "y"].include?(ans)
      ans = "yes"
      true_count += 1
    elsif ["no", "n"].include?(ans)
      ans = "no"
    end
      
    $store.transaction do 
      $store[question_key.to_sym] = ans
    end
    rating = (100 * true_count)/QUESTIONS_COUNT
    print " rating is: #{rating} "
  end
end

def do_report
  # TODO: IMPLEMENT
  true_count = 0
  false_count = 0
  $store.transaction(true) do
    $store.roots.each do |question_key|
      value = $store[question_key.to_sym]
      if value == "yes" 
        true_count += 1
      else
        false_count += 1
      end
    end
  end

  true_avg_rating = true_count.to_f/QUESTIONS_COUNT
  false_avg_rating = false_count.to_f/QUESTIONS_COUNT
  print "true_avg_rating: #{true_avg_rating} "
  print "false_avg_rating: #{false_avg_rating} "      
end

do_prompt
do_report



RSpec.describe "User Survey" do
  describe "#do_prompt" do
    it "prompts the user with questions and stores responses in the store" do
      allow_any_instance_of(Object).to receive(:gets).and_return("yes", "no", "yes", "no", "yes")
      expect($store).to receive(:transaction).exactly(QUESTIONS_COUNT).times
      do_prompt
    end

     it "user rating calculated with yes ans" do
      allow_any_instance_of(Object).to receive(:gets).and_return("yes", "no", "y", "abc", "@")
      expect { do_prompt }.to output("Can you code in Ruby? rating is: 20 Can you code in JavaScript? rating is: 20 Can you code in Swift? rating is: 40 Can you code in Java? rating is: 40 Can you code in C#? rating is: 40 ").to_stdout
    end
  end

  describe "#do_report" do
    it "generates a report based on user responses" do
      allow($store).to receive(:transaction).and_yield
      allow($store).to receive(:roots).and_return(["q1", "q2", "q3", "q4", "q5"])
      allow($store).to receive(:[]).with(:q1).and_return("yes")
      allow($store).to receive(:[]).with(:q2).and_return("no")
      allow($store).to receive(:[]).with(:q3).and_return("yes")
      allow($store).to receive(:[]).with(:q4).and_return("no")
      allow($store).to receive(:[]).with(:q5).and_return("yes")

      expect { do_report }.to output("true_avg_rating: 0.6 false_avg_rating: 0.4 ").to_stdout
    end
  end
end


RSpec::Core::Runner.run([])







