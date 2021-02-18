file = __FILE__
parent = File.expand_path("..", Dir.pwd)
file = file.split(".")[0]
@path_html = "#{parent}/#{file}/#{file}_A.html"
require_relative '../scrape.rb'
input = @input
output = @output

# puts input

# cp = current position, in terms of index
# items on hand = i
# time = t
def solve(p,d)
    cp = 0
    k = 0

    pos = p
    delta = d
    time = pos[0]

    while delta.any? { |n| n < 0 }

        if cp!=0
            time+=pos[cp]-pos[cp-1]
        end
        # has supply
        if delta[cp]>0
            k+=delta[cp]
            delta[cp] = 0
        else
            if k > delta[cp].abs
                k+=delta[cp]
                delta[cp] = 0
            end
        end

        # print "currently at #{cp}"
        # print delta
        # puts "On hand = #{k}"
        # If not enough on hand to meet demand on the left, including current point, keep moving right
        if k < delta[0..(cp)].sum.abs
            # puts "not enough at #{cp}"
        
        # if enough, move all the way to the left-most one with demand,
        # then move back to current position, then move 1 step to the right
        else 
            # puts "enough at #{cp}"
            move_to = cp
            for j in (0..(cp))
                if delta[j]<0
                    move_to = j
                    break
                end
            end

            for j in (move_to..cp)
                k+=delta[j]
                delta[j]=0
            end
            if move_to < cp
                # puts "move back to #{move_to}"
                time+=(pos[cp]-pos[move_to])*2
            end
        end

        # print "\n"
        # print "\n"

        if delta.any? { |n| n < 0 }
            cp+=1
            next
        else
            break
        end

    end


    to = cp
    for j in (0..(cp))
        if delta[j]>0
            to = j
            break
        end
    end


    time += pos[-1]-pos[to]
    return time
end



# for i in (7..7)
for i in (0..(input.length()-1))
    part =  input[i].partition('}')
    @hm = Hash.new
    pos =part.first.tr('{} ','').split(',')
    delta = part.last[1..-1].tr('{} ','').tr("\n","").split(",")
    
    p = []
    d = []

    for j in (0..(pos.length-1))
        p.append(pos[j].to_i)
        d.append(delta[j].to_i)
    end

    # print p
    # print "\n"
    # print d
    # puts "\n\n"
    solution = solve(p,d)

    if solution==(output[i].to_i)
        puts "Test Case #{i},  Output: #{solution} , Expected Output: #{output[i]} ==> Passed"
    else
        puts "Test Case #{i},  Output: #{solution} , Expected Output: #{output[i]} ==> Failed"
    end
end
