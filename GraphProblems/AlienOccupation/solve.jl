# set JULIA_NUM_THREADS=16
# Threads.@threads

using XLSX
using DataStructures
import Missings
using ThreadsX


pwd()

xl = XLSX.readxlsx("data.xlsx")
matrix = xl["Sheet1"]["A1:C200"]
# matrix = coalesce.(matrix, 0)
# println(file)

function custom_split(input,output)
    na = split(input, ",";limit=3)

    N = na[1]
    A = na[2]

    xy = na[3]
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
    A= parse(Int64,A)

    Y = [parse(Int64,i) for i in Y]
    X = [parse(Int64,i) for i in X]
    O = [parse(Int64,i) for i in O]
    return N,A,X,Y,O
end

function solve(N,A,X,Y,O)

    T =0
    U =0
    V = 0

    # Visited is zero-index
    visited = [0 for i in 1:N]
    visited[A+1] = 1
    pq = PriorityQueue()
    enqueue!(pq,A,1)

    while (!isempty(pq))
        v = 0
        targets= []

        temp_pq = PriorityQueue()
        while (!isempty(pq))
            v+=1
            p  = dequeue!(pq)
            P = @. X * p + Y


            # For speedup, try to use less for loops
            Threads.@threads for i in P
                if ((visited[i%N+1]==0))
                    visited[i%N+1]=1
                    enqueue!(temp_pq,i%N,1)
                    append!(targets,i%N)
                    # println(i%N+1)
                    # println("Visited: ", visited)
                end
            end
        end

        # update max number of targets in any given year
        if (length(targets)>V)
            V = length(targets)
        end


        pq = copy(temp_pq)
        # println(pq)
        if !isempty(pq)
            U+=1
        end
    end

    T = sum(visited)
    return [T,U,V]
end


# for j in 4:5
function results(matrix)
    Threads.@threads for j in 1:size(matrix)[1]
        println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = matrix[j,3]

            N, A,X,Y,O =custom_split(input,output)
            # println(N)
            # println(A)
            # println(X)
            # println(Y)
            # println(O)
            # println("\n")
            res = @time solve(N,A,X,Y,O)
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


# Parallel loop function results and function solve: runtime ~150 seconds
# No paralle loop: runtime ~548 seconds
# Parallel loop function solve only: error encountered
# Parallel loop function results only: ~190 seconds
# Add ThreadX for sum and list comprehension: ~ 164 seconds
