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




function custom_split(input)
    na = rsplit(input, "}";limit=3)

    N = na[1]
    Y = na[2]

    N = replace.(N, ['{',' '] => "")
    Y = replace.(Y, ['"',' ','{']  => "")

    N = split(N,",")
    Y = split(Y,",")[2:end]

    N = [parse(Int64,i) for i in N]

    d = zeros(Int64, size(N)[1], size(N)[1])
    i = 1
    while i <= size(Y)[1]
        j = 1
        while j <= length(Y[i])
            if Y[i][j:j] == "Y"
                d[i,j] = 1
            end
            j+=1
        end
        i+=1
    end


    # for i = 1 : size(d)[1]
    #     println(d[i,:])
    # end
    return N,d
end


function sum_rows(matrix)
    n= size(matrix)[1]
    sum = [0 for i = 1:n]
    for i = 1 : n
        for j = 1: n
            sum[i] = sum[i] + matrix[j,i]
        end
    end
    return sum
end

function points_visited(array,n)
    result = [0 for i=1:n]
    for i in array
        for ii in i
            result[ii]=1
        end
    end
    return result
end


function solve(N,d)
    time = Dict()
    n = size(d)[1]
    visited = [0 for i in 1:n]
    t = [0 for i in 1:n]

    while (0 in t)
        next = Dict()
        for i = 1:n
            if visited[i]==0
                # if all required tasks to do i have been completed
                if !(0 in (visited .>= d[:,i]))
                    next[i] = d[:,i]
                end
            end
        end

        # Cant do any more tasks
        if length(collect(keys(next)))==0
            return -1
        end
        # println("Next tasks: ", next)

        # given a task i to be executed, find the time for all of the precedent tasks
        # the time for the longest precedent task + time to complete i, will be the total time required to complete i
        for i in keys(next)
            max_t = 0
            for j =1:n
                if d[j,i]==1 && t[j]>max_t
                    max_t=t[j]
                end
            end

            t[i] = max_t + N[i]
            visited[i] = 1
        end
        # println("\n")
    end
    # println(t)

    return maximum(t)
end



function results(matrix)
    # for j in 18:18
    for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = parse(Int64,matrix[j,3])

            N,d =custom_split(input)
            res = solve(N,d)
            # println(res)
            # println(output)

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
