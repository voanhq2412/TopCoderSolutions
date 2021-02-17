file = __FILE__
parent = File.expand_path("..", Dir.pwd)
file = file.split(".")[0]
@path_html = "#{parent}/#{file}/#{file}_A.html"
require_relative '../scrape.rb'
input = @input
output = @output

# puts input

# t = totla smiles
# c= clipboard
# a = previous action
def solve(goal,t,c,a=nil)
    # if previous was copy, then next must be paste
    # but paste could come after paste
    if c==0
        return solve(goal,t,1,"c")
    elsif t==goal
        return 0
    elsif t>goal
        return 1.0/0.0
    else
        if a=="c"
            return 1 + solve(goal,t,c,"p")
        elsif a=="p"
            return 1 + [solve(goal,t+c,t+c,"c") , solve(goal,t+c,c,"p")].min
        end
    end
end



for i in (0..(input.length()-1))

    part =  input[i].partition('}')
    pos =part.first.tr('{} ','').split(',')
    delta = part.last[1..-1].tr('{} ','').tr("\n","").split(",")

    print delta
    puts "\n\n"
    # solution = solve(pos,delta)
#     if solution==(output[i].to_i)
#         puts "Test Case #{i}, Input: #{input[i]} , Output: #{solution} , Expected Output: #{output[i]} ==> Passed"
#     else
#         puts "Test Case #{i}, Input: #{input[i]} , Output: #{solution} , Expected Output: #{output[i]} ==> Failed"
#     end
end
