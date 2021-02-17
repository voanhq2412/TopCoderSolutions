require 'nokogiri'
require 'daru'


puts @path_html
doc = Nokogiri::HTML(File.open(@path_html))
html = doc.xpath("//*[contains(text(), 'System Test Results')]/../../..")
tables = doc.search('table')
table = tables.last
row = table.xpath(".//tr[@class='alignTop']")

@input = []
@output = []
row.each do |i|
    k = i.xpath(".//td[@class='statText']")
    @input.push(k[0].xpath(".//text()").to_s)
    @output.push(k[1].xpath(".//text()").to_s)
end

