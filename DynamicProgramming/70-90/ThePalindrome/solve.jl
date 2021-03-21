# set JULIA_NUM_THREADS=16
# Threads.@threads

using XLSX
using DataStructures
import Missings
using ThreadsX


pwd()

xl = XLSX.readxlsx("data.xlsx")
matrix = xl["Sheet1"]["A1:C200"]
# # matrix = coalesce.(matrix, 0)
# # println(file)


function palindrome_range(input)
    if length(input)==1 || length(input)==0
        return true
    elseif input[1:1]==input[end:end]
        return palindrome_range(input[2:(end-1)])
    else
        return false
    end
end



function solve(input)

    bool = false
    n = length(input)
    range = []
    for i=1:n
        bool = palindrome_range(input[i:n])
        if bool
            range = [i,n]
            break
        else 
            continue
        end
    end

    # println(range)
    return n + range[1]-1
end



function results(matrix)
    # for j in 1:10
    for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = parse(Int64,matrix[j,3])
            input = replace(input,['"'] => "")

            # println(input)
            # palindrome_range(input)
            res = solve(input)
            # println(res)
            # # # println(output)

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
