# set JULIA_NUM_THREADS=16
# Threads.@threads

using XLSX
using DataStructures
import Missings
using ThreadsX


pwd()

xl = XLSX.readxlsx("data.xlsx")
matrix = xl["Sheet1"]["A1:C200"]




function custom_split(input)
    na = replace(input,['{','}','"'] => "")
    N = split(na,",")

    array = PriorityQueue()
    for n=1:length(N)
        s = split(N[n]," ")
        s = [parse(Int64,i) for i in s if i!=""]
        enqueue!(array,[n,s],n)
    end
    return array
end

# N is (remaining) digits
# d = sum we need (max is 100)

function solve(N)

    while !isempty(N)
        costs = dequeue!(N)[2]
        temp = Dict()
        if isempty(hm)
            global hm["R"] = costs[1]
            global hm["G"] = costs[2]
            global hm["B"] = costs[3]
        else 
            for (k,v) in hm
                if k=="R"
                    if haskey(temp,"G")
                        temp["G"]= min(hm["R"]+costs[2],temp["G"])
                    else
                        temp["G"]= min(hm["R"]+costs[2])
                    end

                    if haskey(temp,"B")
                        temp["B"]= min(hm["R"]+costs[3],temp["B"])
                    else
                        temp["B"]= min(hm["R"]+costs[3])
                    end

                elseif k=="G"
                    if haskey(temp,"R")
                        temp["R"]= min(hm["G"]+costs[1],temp["R"])
                    else
                        temp["R"]= min(hm["G"]+costs[1])
                    end

                    if haskey(temp,"B")
                        temp["B"]= min(hm["G"]+costs[3],temp["B"])
                    else
                        temp["B"]= min(hm["G"]+costs[3])
                    end

                elseif k=="B"
                    if haskey(temp,"R")
                        temp["R"]= min(hm["B"]+costs[1],temp["R"])
                    else
                        temp["R"]= min(hm["B"]+costs[1])
                    end

                    if haskey(temp,"G")
                        temp["G"]= min(hm["B"]+costs[2],temp["G"])
                    else
                        temp["G"]= min(hm["B"]+costs[2])
                    end
                end
            end
            global hm = copy(temp)
            # println(hm)
        end
    end
    return minimum(collect(values(hm)))
end



function results(matrix)
    # for j in 1:2
    for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = parse(Int64,matrix[j,3])

            global hm = Dict()
            N =custom_split(input)
            # println(N)
            res = solve(N) 

            if res == output
                println("Test Case ",j, ": Passed")
                # println("\n\n\n\n")
                continue
            else
                println("Test Case ",j, ": Failed")
                break
            end
        else
            continue
        end
    end
    
end

@time results(matrix)


# # No paralle loop: runtime ~0.5 seconds
# runtime so low already, parallel will add overhead costs and make it slower
