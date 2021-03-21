# set JULIA_NUM_THREADS=16
# Threads.@threads

using XLSX
using DataStructures
import Missings
using ThreadsX


pwd()

xl = XLSX.readxlsx("data.xlsx")
matrix = xl["Sheet1"]["A1:C200"]


function custom_split(input,output)
    na = rsplit(input, ",";limit=2)
    N = na[1]
    area = parse(Float64,na[2])

    N = replace.(N, "{" => "")
    N = replace.(N, "}" => "")
    N = replace.(N, " " => "")
    N = replace.(N, '"'  => "")
    N = split(N,",")

    cave = Array{String}(undef, length(N), length(N[1]))
    for i=1:length(N)
        for j=1:length(N[1])
            cave[i,j] = N[i][j:j]
        end
    end
    return cave,area
end

function solve(N,A)
    Y  = size(N)[1]
    X = size(N)[2]
    x = 0
    y = 0

    for j = 1:Y
        for k = 1:X
            if N[j,k] == "."
                x = k
                y = j
                @goto escape
            end
        end
    end
    @label escape


    # Breath First Search
    visited = zeros(Float64,Y,X)
    pq = PriorityQueue()
    enqueue!(pq,[y,x],1)


    while (!isempty(pq))
        get = dequeue!(pq)
        # println("exploring surroundings of ",get[1], " ",get[2])

        if visited[get[1],get[2]] == 1
            continue
        else

            visited[get[1],get[2]] = 1

            # if get[1]==50 && get[2]==49
            #     println(N[get[1],get[2]])
            #     println("not yet visited")
            # end
            # if N[get[1],get[2]]=="K"
            #     println("BLADSADASDAS")
            #     println(get[1]," ",get[2])
            # end
            N[get[1],get[2]] = "."
            # println("\n")
        end

        # Walk up 1
        try
            # up right 1
            if ( N[get[1]-1,(get[2]+1):(get[2]+1)][1] =="K")
                @goto not_right
            end
        catch e
        end

        try
            # up left 1
            if (N[get[1]-1,(get[2]-1):(get[2]-1)][1]=="K")
                @goto not_up
            end
        catch e
        end

        try
            # up 2
            if (N[get[1]-2,get[2]:get[2]][1]=="K")
                @goto not_up
            end
        catch e
        end

        try
            # up 1
            if (Y>=get[1]-1>=1)&&(X>=get[2]>=1)
                # println("added ", get[1]-1," ",get[2]," to queue")
                enqueue!(pq,[get[1]-1,get[2]],1)
                # if (get[1]-1==49) && (get[2]==49)
                #     println("exploring surroundings of ",get[1], " ",get[2])
                # end
            end
        catch e
        end
        @label not_up



        # Walk right 1
        try
            # down right 1
            if (N[get[1]+1,(get[2]+1):(get[2]+1)][1]=="K")
                @goto not_down
            end
        catch e
        end

        try
            # right 2
            if (N[get[1],(get[2]+2):(get[2]+2)][1]=="K")
                @goto not_right
            end
        catch e
        end

        try
            #right 1
            if (Y>=get[1]>=1)&&(X>=get[2]+1>=1)
                # println("added ", get[1]," ",get[2]+1," to queue")
                enqueue!(pq,[get[1],get[2]+1],1)
                # if (get[1]==49) && (get[2]+1==49)
                #     println("exploring surroundings of ",get[1], " ",get[2])
                # end
            end
        catch e
        end
        @label not_right



        # Walk down 1
        try
            # down left 1
            if (N[get[1]+1,(get[2]-1):(get[2]-1)][1]=="K")
                @goto not_left
            end
        catch e
        end


        try
            # down 2
            if (N[get[1]+2,(get[2]):(get[2])][1]=="K")
                @goto not_down
            end
        catch e
        end

        try
            # down 1
            if (Y>=get[1]+1>=1)&&(X>=get[2]>=1)
                # println("added ", get[1]+1," ",get[2]," to queue")
                enqueue!(pq,[get[1]+1,get[2]],1)
                # if (get[1]+1==49) && (get[2]==49)
                #     println("exploring surroundings of ",get[1], " ",get[2])
                # end
            end
        catch e
        end
        @label not_down


        # Walk left 1
        try
            # up left 1
            if (N[get[1]-1,(get[2]-1):(get[2]-1)][1]=="K")
                @goto not_left
            end
        catch e
        end

        try
            # up 2
            if (N[get[1],(get[2]-2):(get[2]-2)][1]=="K")
                @goto not_left
            end
        catch e
        end

        try
            # left 1
            if (Y>=get[1]>=1)&&(X>=get[2]-1>=1)
                # println("added ", get[1]," ",get[2]-1," to queue")
                enqueue!(pq,[get[1],get[2]-1],1)
                # if (get[1]==49) && (get[2]-1==49)
                #     println("exploring surroundings of ",get[1], " ",get[2])
                # end
            end
        catch e
        end
        @label not_left



    end

    # println("Area = ", sum(visited))
    # for i = 1 : Y
    #     println(N[i,:])
    # end


    return sum(visited)
end



function results(matrix)
    # for j in 10:10
    Threads.@threads for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = matrix[j,3]

            N, A =custom_split(input,output)
            # println(N)
            # println(A)

            # println("\n")
            res = solve(N,A)
            if (res >= A && output!="{}") || (res < A && output=="{}")
                println("Test Case ",j, ": Passed")
                # println("\n\n\n\n")
                continue
            elseif (res < A && output!="{}") || (res >= A && output=="{}")
                println("Test Case ",j, ": Failed")
                break
            end
        else
            continue
        end
    end
end

@time results(matrix)


# No paralle loop: runtime ~3.2 seconds
# Parallel loop function results only: ~2.8 seconds
