file = __FILE__
parent = File.expand_path("..", Dir.pwd)
file = file.split(".")[0]
@path_html = "#{parent}/#{file}/#{file}_A.html"
require_relative '../scrape.rb'
input = @input
output = @output



# t = totla smiles
# c= clipboard
# a = previous action
def solve(n)
    i = 0
    while i <= n
        if i<=2
            if i==2
                @hm[i] = [3,2,2,4]
            else 
                @hm[i] = [1,0,1,1]
            end
        else 
            n_1 = @hm[i-1]
            @hm[i] = [n_1[0]+n_1[2],n_1[2],n_1[3]*2-n_1[2],n_1[3]*2]
        end

        if i >=4
            @hm.delete(i-2) 
        end     
        i+=1
    end
end



for i in (0..(input.length()-1))

    # info saved in hashmap: 
    # keys  = n
    # values = #cars, empty, non empty , #nodes
    # where 'empty': number of nodes that is travlled by only 1 car, and that car doesn't go anywhere else
    # non_empty  = the rest of the nodes
    # #nodes= numb nodes at bottom level 
    @hm = Hash.new
    n = input[i].to_i
    solve(n)
    solution = @hm[n][0]
    
    # puts @hm
    # puts "n = #{n} ; solution = #{solution}"
    # puts "\n\n\n"
    if solution==(output[i].to_i)
        puts "Test Case #{i}, Input: #{input[i]} , Output: #{solution} , Expected Output: #{output[i]} ==> Passed"
    else
        puts "Test Case #{i}, Input: #{input[i]} , Output: #{solution} , Expected Output: #{output[i]} ==> Failed"
    end

end