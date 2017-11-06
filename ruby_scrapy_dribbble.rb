require "mechanize"
require "Pry"

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'


limit = ARGV.pop.to_i
img_count = 0
search_param = ARGV.join("+")

# puts search_param

url = "https://dribbble.com/search?q=#{search_param}"

page = agent.get(url)

# Pry.start(binding)

# 存放缩略图的 link 用于点击打开 modal
links_dribbble = []

page.links.each do |link|
  next if links_dribbble.any? {|exist_link| exist_link.href == link.href }
  if (link.href =~ /^\/shots\/\d+-.+/) && (link.href.count('/') == 2)
    puts link.href + " Look at here!"
    links_dribbble.push(link)
  end
end

puts links_dribbble.length

links_dribbble.each do |link|
  page_modal = link.click
  # Pry.start(binding)

  author = page_modal.css(".slat-header > a")[0].attributes["title"].value

  unless page_modal.css(".single-img > picture").empty?
    page_modal.css("picture > source").each do |node|
      # puts node.to_html
      if node.attributes["srcset"].value =~ /^https:\/\/cdn\.dribbble\.com\/users\/\d+\/screenshots\/\d+\/.+/
        pic_src = node.attributes["srcset"].value
        # puts author
        puts pic_src
        agent.get(pic_src).save "images/#{author}/#{File.basename(pic_src)}"
        img_count += 1
        puts img_count
        if img_count > limit
          system(exit)
        end
      end
    end
  else
    pic_src = page_modal.css(".single-img > img")[0].attributes["src"].value
    # puts author
    puts pic_src
    agent.get(pic_src).save "images/#{author}/#{File.basename(pic_src)}"
    img_count += 1
    puts img_count
    if img_count > limit
      system(exit)
    end
  end
end
