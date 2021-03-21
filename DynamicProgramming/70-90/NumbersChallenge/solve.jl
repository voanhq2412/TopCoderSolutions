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
    N = replace(input,['{',' ','}'] => "")
    na = split(N, ",")
    na = [parse(Int64,i) for i in na]
    return na
end
# N is (remaining) digits
# d = sum we need (max is 100)

function solve(N,s)
    #pick N[1] 
    if s == 0
    else
        global sums[s]=1
    end

    if length(N)==0
    else
        solve(N[2:end],s+N[1])
        solve(N[2:end],s) 
    end
end


function results(matrix)
    # for j in 2:11
    for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = parse(Int64,matrix[j,3])

            N =custom_split(input)
            N = sort(N)
            start = 0

            
            global sums = [0 for i=1:2000000]
            # println("Input: ", N)

            solve(N,start)
            res = findfirst(isequal(0),sums)

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
