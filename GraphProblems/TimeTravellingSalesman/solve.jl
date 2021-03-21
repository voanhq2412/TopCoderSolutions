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
    na = split(input, ",";limit=2)

    N = na[1]
    A = na[2]

    A = replace.(A, '{' => "")
    A = replace.(A, '}' => "")
    A = split(A,'"')

    string = ""
    for i = 1:length(A)
        if (A[i]==", ")
            continue
        else
            string = string*A[i]
        end
    end

    string = rstrip(string)
    string = lstrip(string)
    # println(string)

    A = split(string," ")
    # println(A)

    # # Parse String to Int64
    N = parse(Int64,N)
    matrix = Array{Float64}(undef, N, N)
    fill!(matrix,Inf)

    for i = 1:length(A)
        get = split(A[i],",")
        get = [parse(Int64,i) for i in get]
        matrix[get[1]+1,get[2]+1] = get[3]
        matrix[get[2]+1,get[1]+1] = get[3]
    end

    return N,matrix
end

function solve(N,matrix)

    # Visited is zero-index
    visited = [0 for i in 1:N]
    visited[1] = 1
    pq = PriorityQueue()
    enqueue!(pq,1,1)

    # Nodes that we cannot get to, return -1
    inf_to_zero = copy(matrix)

    replace!(inf_to_zero, Inf=>0)
    s = sum(inf_to_zero,dims=1)
    if (0 in s)
        return -1
    end

    res = 0
    # for i =1:N
        # println(matrix[i,:])
    # end
    #

    while (!isempty(pq))
        get = dequeue!(pq)

        Threads.@threads for i=1:N
            # from current node, for the nodes that we can get to ...
            # if cost is min for that whole column then add to queue.
            if (matrix[get,i]==minimum(matrix[:,i])) && (visited[i]!=1) && !(i in keys(Dict(pq)))
                # println("add node ", i, " to queue", )
                enqueue!(pq,i,matrix[get,i])
                res+=matrix[get,i]
                visited[i] = 1
            end
        end


        # If empty search for min cost place we get can to given all the visited nodes
        if isempty(pq) && sum(visited)<N
            to = 1
            min = Inf
            for r = 1:N
                for c = 1:N
                    if (visited[r]==1) && (visited[c]==0) && (matrix[r,c]<min)
                        min = matrix[r,c]
                        to = c
                    end
                end
            end

            if to == 1
                return -1
            end

            enqueue!(pq,to,min)
            res+=min
            visited[to] = 1
            # println("min: add node ", to, " to queue", )
        end

        # # Cant go anywhere else, no solution
        # if isempty(pq) && sum(visited)<N
        #     return -1
        # end
    end
    # for i = 1:N
    #     println(journey[i,:])
    # end


    return res
end


# for j in 4:5
function results(matrix)
    # for j in 41:41
    Threads.@threads for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = matrix[j,3]

            N, A =custom_split(input,output)
            O = parse(Float64,output)
            # println(N)
            # println(A)

            # println("\n")
            res =solve(N,A)
            # println(res)
            # println(O)
            # println("done")
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


# Parallel loop function results and all loops in function solve: runtime ~2.20 seconds
# Parallel loop function results and 1st loop in function solve: runtime ~2.05 seconds
# No paralle loop: runtime ~2.58 seconds
# Parallel loop function results only: ~2.13 seconds
