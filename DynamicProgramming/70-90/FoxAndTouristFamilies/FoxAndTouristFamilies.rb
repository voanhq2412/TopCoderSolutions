file = __FILE__
parent = File.expand_path("..", Dir.pwd)
file = file.split(".")[0]
@path_html = "#{parent}/#{file}/#{file}_A.html"
require_relative '../scrape.rb'
input = @input
output = @output
$VERBOSE = nil

require 'algorithms'



# cp = current position, in terms of index
# items on hand = i
# time = t
def solve(matrix,f)
    hm = Hash.new
    n = matrix.length-1

    for i in (0..n)
        for j in (0..n)
            if i!=j && !hm.include?([i,j].sort)
                hm[[i,j]] = bfs(matrix,i,j) 
            end
        end
    end
    
    starting = Array.new(n+1).fill(0)
    for i in (0..(f.length-1))
        starting[f[i]] += 1
    end

    full_road = Hash.new
    for i in (0..(starting.length-1))
        if starting[i]>0
            prob = paths(hm,i)
            prob.each do |key, value|
                if full_road.include?(key)
                    full_road[key] *= value**starting[i] 
                else 
                    full_road[key] = value**starting[i] 
                end
            end
        end
    end 

    expected_full = 0
    full_road.each do |key, value|
        expected_full+=value
    end

    # puts "Starting at: #{starting}"
    # puts full_road
    # puts "Expected #full roads = #{expected_full}"
    # print "\n\n"
    return expected_full
end


def paths(hm,start)
    relevant_paths = Hash.new
    hm.each do |key, value|
        if key.include?(start)
            relevant_paths[key]=value
        end
    end

    final = Hash.new
    relevant_paths.each do |key, value|
        for i in (0..(value.length-2))
            if final.include?([value[i],value[i+1]].sort)
                final[[value[i],value[i+1]].sort]+=1.0/relevant_paths.length
            else 
                final[[value[i],value[i+1]].sort]=1.0/relevant_paths.length
            end
        end
    end
    # puts final
    return final
end
# neeed to find path from one place to another, these paths arre gonna get called multipe times, so save them 
# ... rather than having to find the paths multiple times. 
def bfs(matrix,f,t)
    n = matrix.length

    q= Queue.new
    q.enq(f)
    visited = Array.new(n)
    visited[f]=1
    prev = Array.new(n)

    while !q.empty?
        get = q.deq
        if get==t
            break
        end
        for i in (0..n)
            if  matrix[get][i]==1 && get!=i && visited[i]!=1
                q.enq(i)
                visited[get]=1
                prev[i]=get
            end
        end
    end

    path = [t]
    while !path.include?(f)
        get = path[-1]
        path.append(prev[get])
    end
    # print path
    return path.reverse
   
end





# for i in (0..10)
for i in (0..(input.length()-1))
    
    out = output[i].to_f.round(10)
    part = input[i].tr('{ ','')
    part =  part.split("}")

    A =part[0].split(',').map(&:to_i)
    B = part[1].tr("\n","").split(",")[1..-1].map(&:to_i)
    f = part[2].tr("\n","").split(",")[1..-1].map(&:to_i)

    n = [B.max,A.max].max
    matrix = Array.new(n+1){ Array.new(n+1).fill(0)}
    for i in (0..(n-1))
        row = A[i]
        col = B[i]
        matrix[row][col] = 1
        matrix[col][row] = 1
    end

    solution = solve(matrix,f).round(10)


    # print A
    # print B
    # print f

    if solution==(out)
        puts "Test Case #{i},  Output: #{solution} , Expected Output: #{out} ==> Passed"
    else
        puts "Test Case #{i},  Output: #{solution} , Expected Output: #{out} ==> Failed"
    end
end
