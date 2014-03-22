set :output, { :standard => nil }

every :day, at: "3:10 am" do
  rake "cicero:purge"
end
