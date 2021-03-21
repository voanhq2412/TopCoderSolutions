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



function custom_split(input,output)
    na = split(input, ",";limit=2)

    N = na[1]
    xy = na[2]
    xy = replace.(xy, '{' => "")


    X =split(xy,"}";limit=2)[1]
    X = split(X,",")

    Y = split(xy,"}";limit=2)[2]
    Y =  replace.(Y, '}'=> "")
    Y = split(Y,",")[2:end]

    o = replace.(output, ['}','{']=> "")
    O = split(o,",")

    # Parse String to Int64
    N = parse(Int64,N)

    Y = [parse(Int64,i) for i in Y]
    X = [parse(Int64,i) for i in X]
    O = parse(Int64,O[1])
    return N,X,Y,O
end


function solve(N,X,Y,O)

    p = length(X)
    d = zeros(Float64, p, p)
    fill!(d,Inf)

    Threads.@threads for j = 1:p
        for k = 1:p
            d[j,k] = max(abs(X[k]- X[j]) + abs(Y[k]- Y[j]) -1,0)
        end
    end
    # println("Initial Array: ", d)


    Threads.@threads for i = 1:p
        for j = 1:p
            for k = 1:p
                d[j,k] = min(d[j,i] + d[i,k], d[j,k])
            end
        end
    end
    return d[1,p]
end


function results(matrix)
    # for j in 18:18
    Threads.@threads for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = matrix[j,3]

            N,X,Y,O =custom_split(input,output)
            # println("Input:")
            # println(N)
            # println(X)
            # println(Y)

            res = solve(N,X,Y,O)
            # println("Output:")
            # println(res)
            # println(O)

            if res == O
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

# # Parallel loop function results and function solve (all for loops): runtime ~8 seconds
# # No paralle loop: runtime ~15 seconds
# # Parallel loop function results only: ~7.3 seconds
# # Parallel loop function results and function solve (outermost for loops only): runtime ~6.1 seconds
# # Parallel loop function results and function solve (innermost for loops only): runtime ~7.8 seconds
# Conclusion: for multiple nested loops, parallel outermost loop
