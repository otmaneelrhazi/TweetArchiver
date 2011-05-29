require "rubygems"
require "twitter"

if(ARGV.size == 0)
  puts "Usage: ruby TweetArchiver [screen name]"
  Process.exit
end

screenName = ARGV[0]
filename = screenName + ".txt"


def readTweetStreamIntoFile(screenName, aFile)
  page=0
  timeline = nil
  while(page == 0 || (timeline != nil && timeline.size > 0))
    puts "Getting page of tweets: " + page.to_s
    begin
      # retrieve page of tweets
      # Documentation for this API: http://rdoc.info/gems/twitter/1.4.1/Twitter/Client/Timeline:user_timeline
      timeline = Twitter.user_timeline(screenName, {"count"=>200, "include_rts"=>true, "page"=>page})

      # check if we got back results
      if(timeline != nil && timeline.size > 0)
        puts "   Loaded page: " + page.to_s
        # process the list of tweets we retrieved
        timeline.each {|tweet| 
          #puts tweet
          aFile.syswrite("Tweeted: " + tweet.created_at + "\n")
          if(tweet.in_reply_to_screen_name != nil)
            aFile.syswrite("Reply To: " + tweet.in_reply_to_screen_name + "\n")
          end
          if(tweet.retweeted_status != nil)
            aFile.syswrite("Reweeted from: " + tweet.retweeted_status.user.screen_name + "\n")
          end
          if(tweet.retweet_count == '0')
            aFile.syswrite("Retweet Count: " + tweet.retweet_count.to_s + "\n")
          end
          #aFile.syswrite("Source: " + tweet.source + "\n")
          aFile.syswrite("\n")
          aFile.syswrite(tweet.text + "\n")
          aFile.syswrite("----------------------------------------------------------------------------------------------------------------------" + "\n")
        }
      
        # increment page so we can try to get the next one
        page+=1
      else
        # we didn't find any results so break out of the loop
        break
      end    
    rescue Exception=>e
      # handle exception
      puts "Error loading page of tweets: " + e.message
      break
    end
  end
  puts "Finished loading timeline for: " + screenName
end

aFile = File.open(filename, "w+") do |aFile|
  puts "Reading tweet stream into file '" + filename + "' for screen_name: " + screenName
  readTweetStreamIntoFile(screenName, aFile)
end


