# def whatever()
#   3.times do
#     puts "1 at #{Time.now}"
#     sleep(2)
#   end
# end
#
# def whatever2()
#   3.times do
#     puts "2 at #{Time.now}"
#     sleep(1)
#   end
# end
#
# t1 = Thread.new {whatever}
# t2 = Thread.new {whatever2}
#
# t1.join
# t2.join

require 'date'

date = Date.today
p date
